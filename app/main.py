from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Float, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, Session
from pydantic import BaseModel
from datetime import date

DATABASE_URL = "postgresql+psycopg2://admin:secret@localhost:5432/mydb"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

app = FastAPI(title="Order Service")

class Client(Base):
    __tablename__ = "clients"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    adress = Column(String)


class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    clientid = Column(Integer, ForeignKey("clients.id"))
    orderDate = Column(Date, default=date.today)
    client = relationship("Client")


class Nomenclature(Base):
    __tablename__ = "nomenclature"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    quantity = Column(Integer)
    price = Column(Float)
    categoryid = Column(Integer)


class OrderNomenclature(Base):
    __tablename__ = "ordernomenclatures"
    id = Column(Integer, primary_key=True, index=True)
    orderid = Column(Integer, ForeignKey("orders.id"))
    nomenclatureid = Column(Integer, ForeignKey("nomenclature.id"))
    quantity = Column(Integer)
    price = Column(Float)
    order = relationship("Order")
    nomenclature = relationship("Nomenclature")

# создаём таблицы, если их нет
Base.metadata.create_all(bind=engine)


class AddProductRequest(BaseModel):
    order_id: int
    nomenclature_id: int
    quantity: int


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI!"}


@app.post("/add_product_to_order")
def add_product_to_order(req: AddProductRequest, db: Session = Depends(get_db)):
    # проверяем существование заказа
    order = db.query(Order).filter(Order.id == req.order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # проверяем наличие товара
    product = db.query(Nomenclature).filter(Nomenclature.id == req.nomenclature_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # проверяем количество товара
    if product.quantity < req.quantity:
        raise HTTPException(status_code=400, detail="Not enough product in stock")

    # проверяем, есть ли этот товар в заказе
    order_item = (
        db.query(OrderNomenclature)
        .filter(OrderNomenclature.orderid == req.order_id,
                OrderNomenclature.nomenclatureid == req.nomenclature_id)
        .first()
    )

    if order_item:
        # увеличиваем количество
        order_item.quantity += req.quantity
    else:
        # создаём новую запись
        order_item = OrderNomenclature(
            orderid=req.order_id,
            nomenclatureid=req.nomenclature_id,
            quantity=req.quantity,
            price=product.price
        )
        db.add(order_item)

    # уменьшаем количество товара
    product.quantity -= req.quantity

    db.commit()
    db.refresh(order_item)

    return {"message": "Product added to order", "order_item_id": order_item.id}
