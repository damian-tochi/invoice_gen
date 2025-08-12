# 📄 Invoice Generator App

A **lightweight**, **offline** invoicing app built with **Flutter**.  
Designed for small business owners and freelancers to create, customize, and manage invoices — all without an internet connection.

---

## 🚀 Features

### 🏠 Home Page
- Quick access to **invoice creation** and **account settings**.

### 🧾 Create Invoice
- Add client name, items, prices, and discounts.
- Auto-calculates totals with tax.
- Import clients from the customer list.

### 👁 Preview Invoice
- View in a **printable** format.
- Includes **logo**, **signature**, and **business details**.

### 🏢 Account Info Management
- Business name and location.
- Inventory type/dealership.
- Upload a logo.
- Persistent storage in **local database**.

### ⚙ Preferences
- Set **up to 2 dominant brand colors**.
- Enable/disable tax and set custom tax rate.
- Upload or draw a **digital signature**.

---

## 🧩 Tech Stack
- **Flutter**
    - State Management: `flutter_bloc`
    - Routing: `get`
- **Local DB:** `hive` (previously `SharedPreferences`)
- **Signature Pad:** [`signature`](https://pub.dev/packages/signature) package
- **File Handling:** `file_picker`, `image_picker`
- **PDF Export (Planned):** `pdf`, `printing`

---

## 🛠 Installation

```bash
git clone https://github.com/yourusername/flutter-invoice-app.git
cd flutter-invoice-app
flutter pub get
flutter run
