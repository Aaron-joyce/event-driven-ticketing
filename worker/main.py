import json
import logging
import os

import boto3
from db import init_db, record_transaction

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)


class SQSWorker:
    def __init__(self, queue_url=None, aws_region=None) -> None:
        self.queue_url = queue_url or os.getenv("SQS_QUEUE_URL")
        self.aws_region = aws_region or os.getenv("AWS_REGION", "us-east-1")

        self.sqs = boto3.client("sqs", region_name=self.aws_region)

    def process_single_message(self, message: dict, db_session=None) -> bool:
        receipt_handle = message["ReceiptHandle"]
        body_raw = message["Body"]

        try:
            payload = json.loads(body_raw)
            logger.info(f"Received ticket message: {payload.get('ticket_id')}")

            required_keys = ["ticket_id", "ticket_type", "quantity", "buyer_name", "buyer_email"]
            for key in required_keys:
                if key not in payload:
                    raise ValueError(f"Missing required field in payload: {key}")

            txn_id = record_transaction(payload, session=db_session)
            logger.info(f"Transaction successfully recorded in DB: {txn_id}")

            self.sqs.delete_message(QueueUrl=self.queue_url, ReceiptHandle=receipt_handle)
            logger.info(f"Deleted message {message['MessageId']} from SQS queue.")
            return True
        except Exception as e:
            logger.error(f"Failed processing message {message.get('MessageId')}: {e!s}")
            return False

    def poll(self, once: bool = False, db_session=None):
        logger.info(f"Starting SQS worker polling on queue: {self.queue_url}")

        while True:
            response = self.sqs.receive_message(
                QueueUrl=self.queue_url, MaxNumberOfMessages=5, WaitTimeSeconds=10
            )

            messages = response.get("Messages", [])
            for msg in messages:
                self.process_single_message(msg, db_session=db_session)

            if once:
                break


if __name__ == "__main__":
    init_db()
    worker = SQSWorker()
    worker.poll()
