import json

import boto3
import pytest
from db import Base, TicketTransaction
from main import SQSWorker
from moto import mock_aws
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker


@pytest.fixture
def db_session():
    """Creates an in-memory SQLite database session for unit testing."""
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.close()


@pytest.fixture
def sqs_queue():
    """Creates a mock SQS queue using moto."""
    with mock_aws():
        sqs = boto3.client("sqs", region_name="us-east-1")
        res = sqs.create_queue(QueueName="test-ticket-queue")
        queue_url = res["QueueUrl"]
        yield queue_url


def test_process_single_message_success(sqs_queue, db_session):
    """Tests that a valid message is processed, recorded in DB, and deleted from SQS."""
    sqs = boto3.client("sqs", region_name="us-east-1")
    
    # 1. Send test ticket message to mock SQS
    test_payload = {
        "ticket_id": "TICK-12345",
        "ticket_type": "VIP",
        "quantity": 2,
        "buyer_name": "Alice Smith",
        "buyer_email": "alice@example.com"
    }
    sqs.send_message(QueueUrl=sqs_queue, MessageBody=json.dumps(test_payload))

    # 2. Receive message from queue
    res = sqs.receive_message(QueueUrl=sqs_queue, MaxNumberOfMessages=1)
    messages = res.get("Messages", [])
    assert len(messages) == 1
    msg = messages[0]

    # 3. Process message using worker
    worker = SQSWorker(queue_url=sqs_queue, aws_region="us-east-1")
    success = worker.process_single_message(msg, db_session=db_session)
    assert success is True

    # 4. Verify record in DB
    record = db_session.query(TicketTransaction).filter_by(ticket_id="TICK-12345").first()
    assert record is not None
    assert record.buyer_name == "Alice Smith"
    assert record.quantity == 2

    # 5. Verify message deleted from SQS
    remaining = sqs.receive_message(QueueUrl=sqs_queue, MaxNumberOfMessages=1)
    assert "Messages" not in remaining or len(remaining["Messages"]) == 0


def test_process_single_message_invalid_payload(sqs_queue, db_session):
    """Tests that an invalid message returns False and is not deleted from SQS."""
    sqs = boto3.client("sqs", region_name="us-east-1")
    
    # Missing required 'buyer_email' field
    invalid_payload = {
        "ticket_id": "TICK-BAD",
        "ticket_type": "VIP",
        "quantity": 1,
        "buyer_name": "Bob"
    }
    sqs.send_message(QueueUrl=sqs_queue, MessageBody=json.dumps(invalid_payload))

    res = sqs.receive_message(QueueUrl=sqs_queue, MaxNumberOfMessages=1)
    msg = res["Messages"][0]

    worker = SQSWorker(queue_url=sqs_queue, aws_region="us-east-1")
    success = worker.process_single_message(msg, db_session=db_session)
    assert success is False

    # DB should have no record
    record = db_session.query(TicketTransaction).filter_by(ticket_id="TICK-BAD").first()
    assert record is None
