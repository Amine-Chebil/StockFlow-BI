import psycopg2
from faker import Faker
import random
from datetime import date, timedelta

fake = Faker()

conn = psycopg2.connect(
    host="localhost",
    database="SurplusStock",
    user="postgres",
    password="put_your_password_here"
)

cursor = conn.cursor()
print("Connected successfully!")

# Insert Categories
categories = ['Textiles', 'Toys', 'Shoes', 'Accessories', 'Electronics']

for category in categories:
    cursor.execute("INSERT INTO Categories (category_name) VALUES (%s)", (category,))

conn.commit()
print("Categories inserted!")

# Insert Suppliers
countries = ['France', 'China', 'Turkey', 'Italy', 'Spain', 'Germany', 'USA']

for _ in range(20):
    cursor.execute(
        "INSERT INTO Suppliers (supplier_name, country, contact_email) VALUES (%s, %s, %s)",
        (fake.company(), random.choice(countries), fake.email())
    )

conn.commit()
print("Suppliers inserted!")

# Insert Products
product_names = {
    'Textiles': ['Cotton Shirts', 'Denim Jackets', 'Wool Scarves', 'Linen Pants', 'Silk Ties'],
    'Toys': ['Toy Cars', 'Lego Sets', 'Stuffed Animals', 'Board Games', 'Puzzles'],
    'Shoes': ['Running Shoes', 'Leather Boots', 'Sandals', 'Sneakers', 'Heels'],
    'Accessories': ['Leather Belts', 'Sunglasses', 'Watches', 'Handbags', 'Wallets'],
    'Electronics': ['Headphones', 'Phone Cases', 'Chargers', 'Keyboards', 'Mice']
}

for category_id, (category, products) in enumerate(product_names.items(), start=1):
    for product in products:
        cursor.execute(
            "INSERT INTO Products (product_name, category_id, supplier_id, quantity, buy_price) VALUES (%s, %s, %s, %s, %s)",
            (product, category_id, random.randint(1, 20), random.randint(50, 500), round(random.uniform(5.0, 200.0), 2))
        )

conn.commit()
print("Products inserted!")

# Insert Customers
for _ in range(50):
    cursor.execute(
        "INSERT INTO Customers (customer_name, customer_email, customer_country) VALUES (%s, %s, %s)",
        (fake.company(), fake.email(), random.choice(countries))
    )

conn.commit()
print("Customers inserted!")

# Insert Orders
start_date = date(2023, 1, 1)
end_date = date(2024, 12, 31)

for _ in range(500):
    order_date = start_date + timedelta(days=random.randint(0, 730))
    product_id = random.randint(1, 25)
    quantity = random.randint(10, 200)
    sell_price = round(random.uniform(10.0, 500.0), 2)
    
    cursor.execute(
        "INSERT INTO Orders (customer_id, product_id, quantity, sell_price, date) VALUES (%s, %s, %s, %s, %s)",
        (random.randint(1, 50), product_id, quantity, sell_price, order_date)
    )

conn.commit()
print("Orders inserted!")