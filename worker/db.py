import os
from uuid import uuid7
from sqlalchemy import create_engine, Column, String, Integer, DateTime, Uuid
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime

def resolve_database_url():
    db_host = os.getenv("DB_HOST")
    db_name = os.getenv("DB_NAME", "ticket_db")
    db_user = os.getenv("DB_USER", "postgres")
    db_pass = os.getenv("DB_PASSWORD")
    if db_host and db_pass:
        return f"postgresql://{db_user}:{db_pass}@{db_host}/{db_name}"
    return os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/ticket_db")

DATABASE_URL = resolve_database_url()

def get_engine(db_url=None):
    url = db_url or resolve_database_url()
    if url.startswith("sqlite"):
        return create_engine(url, connect_args={"check_same_thread": False})
    return create_engine(url)

engine = get_engine()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class TicketTransaction(Base):
    __tablename__ = "ticket_transactions"

    id = Column(Uuid, primary_key=True)
    ticket_id = Column(String, nullable=False)
    ticket_type = Column(String, nullable=False)
    quantity = Column(Integer, nullable=False)
    buyer_name = Column(String, nullable=False)
    buyer_email = Column(String, nullable=False)
    processed_at = Column(DateTime, default=datetime.utcnow)


def init_db(target_engine=None):
    eng = target_engine or engine
    Base.metadata.create_all(bind=eng)

def record_transaction(payload: dict, session=None) -> str:
    db = session or SessionLocal()
    try:
        transaction = TicketTransaction(
            id=uuid7(),
            ticket_id=payload["ticket_id"],
            ticket_type=payload["ticket_type"],
            quantity=payload["quantity"],
            buyer_name=payload["buyer_name"],
            buyer_email=payload["buyer_email"]
        )

        db.add(transaction)
        db.commit()
        db.refresh(transaction)
        return str(transaction.id)
    except Exception as e:
        db.rollback()
        raise e
    finally:
        if not session:
            db.close()
