# 🎓 Student Management System (SMS) – SQL Server Project

This is my **first complete SQL project**, built to understand real-world database design and SQL Server development.  
The entire solution is implemented using **a single SQL script (`StudentManagementDB_Full.sql`)**, which creates:

- Database & schema  
- Tables with PK/FK constraints  
- Stored Procedures  
- Views  
- Scalar Functions  
- Trigger-based audit logging  
- 300 sample students + enrollments + attendance  
- ER Diagram & output screenshots  

This project is designed so **anyone can run it instantly in SSMS** and explore a complete relational system.

---

## 🚀 Features Included

### 🗂️ 1. Database Schema (`acad`)

The script creates these tables:

- Departments  
- Courses  
- Students  
- Enrollments  
- Attendance  
- Instructors  
- ChangeLog (audit table)

All tables include:

- Primary Keys  
- Foreign Keys  
- Constraints  
- Indexes  
- Defaults  

---

## ⚙️ 2. Stored Procedures

| Procedure         | Description                                  |
|------------------|----------------------------------------------|
| `spAddStudent`   | Inserts a new student and logs the action    |
| `spEnrollStudent`| Enrolls a student with validation            |
| `spUpdateStudent`| Updates student details safely               |

---

## 👁️ 3. View

| View Name                | Description |
|-------------------------|-------------|
| `vwStudentEnrollments`  | Combines student, course, and department data for reporting |

This simplifies analytics and eliminates repetitive JOINs.

---

## 🧮 4. Scalar Function

| Function          | Purpose |
|-------------------|---------|
| `fnCalculateAge`  | Calculates age from DOB with year/month precision |

---

## 🔥 5. Trigger

| Trigger Name            | Purpose |
|-------------------------|---------|
| `trg_Students_Audit`    | Logs INSERT/UPDATE operations to `ChangeLog` |

This demonstrates enterprise-style auditing.

---

## 📊 6. Sample Data Generation

The script automatically generates:

- 300 student records  
- Random enrollments per student  
- 200 attendance entries  
- Complete audit logs  

This makes the database immediately ready for demos and learning.

---

## 🛠️ How to Run

1. Open **SQL Server Management Studio (SSMS)**  
2. Open `StudentManagementDB_Full.sql`  
3. Run the script (**F5**)  

The script will:

- Drop database if it already exists  
- Recreate a fresh schema  
- Build tables, procedures, functions, triggers  
- Insert sample data  
- Show test queries  

---

## 🧩 ER Diagram

![ER Diagram](Outputs/SMS ER diagram.png)

---

## 🧪 Screenshots & Outputs

### 🎯 Students Table
![Students](Outputs/SMS Students.png)

### ⚙️ Stored Procedure Execution
![SP](Outputs/SMS SP.png)

### 👁️ View Results
![View](Outputs/SMS view.png)

### 🔥 Trigger Logging
![Trigger](Outputs/SMS Trigger.png)

### 🧮 Function Usage
![Function](Outputs/SMS Function.png)

---

## 📂 Project Structure

StudentManagementSystem-SQL/
│
├── StudentManagementDB_Full.sql # Full database installer script
├── README.md # Documentation
└── Outputs/ # Screenshots & ER Diagram
├── SMS ER diagram.png
├── SMS Students.png
├── SMS SP.png
├── SMS view.png
├── SMS Trigger.png
└── SMS Function.png

---

## 🎓 What I Learned

- Database normalization & schema design  
- Implementing PK/FK relationships  
- Writing Stored Procedures  
- Creating Views for reporting  
- Building Functions for calculations  
- Trigger-based auditing  
- Sample data automation  
- GitHub documentation & project structuring  

---

## ⭐ Support

If you like this project, please ⭐ star the repository!  
Your feedback is always welcome.

---

## 🤝 Connect With Me
I'm open to learning, collaboration, and improving my SQL development skills.
