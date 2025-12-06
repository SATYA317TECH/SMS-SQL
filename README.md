# 🎓 Student Management System (SMS) – SQL Server Project

This is my **first complete SQL project**, built to understand real-world database design and SQL Server development.  
The entire solution is implemented using a **single SQL script (`SMS.sql`)**, which creates:

- Database & schema  
- All tables with PK/FK constraints  
- Stored Procedures  
- Views  
- Scalar Functions  
- Trigger-based audit logging  
- 300 sample student records + enrollments + attendance  
- ER Diagram & output screenshots  

This project is designed so **anyone can run it instantly in SSMS** and explore a complete relational system.

---

## 🚀 Features Included

### 🗃️ 1. Database Schema (`acad`)

The script creates a complete academic system with the following tables:

- **Departments**  
- **Courses**  
- **Students**  
- **Enrollments**  
- **Attendance**  
- **Instructors**  
- **ChangeLog** (audit table)

All tables include:

- Primary Keys (PK)  
- Foreign Keys (FK)  
- Constraints  
- Indexes  
- Defaults  

---

## ⚙️ 2. Stored Procedures

Reusable business logic for consistent operations:

| Procedure | Purpose |
|----------|---------|
| `spAddStudent` | Inserts a new student & logs the action |
| `spEnrollStudent` | Enrolls a student with validation |
| `spUpdateStudent` | Safely updates student details |

---

## 👁️ 3. View

| View Name | Description |
|----------|-------------|
| `vwStudentEnrollments` | Combines student, course, and department details for reporting |

This simplifies analytics and eliminates repetitive JOINs.

---

## 🧮 4. Scalar Function

| Function | Purpose |
|---------|---------|
| `fnCalculateAge` | Calculates accurate age from Date of Birth |

Useful for dashboards and analytics.

---

## 🔥 5. Trigger

| Trigger | Purpose |
|---------|---------|
| `trg_Students_Audit` | Automatically logs INSERT/UPDATE actions into `ChangeLog` |

This demonstrates enterprise-level auditing.

---

## 📊 6. Sample Data Generation

The script automatically generates:

- **300 student records**  
- Random enrollments for each student  
- **200 attendance entries**  
- Full audit logs  

This makes the database immediately usable for demos and testing.

---

## 🛠️ How to Run This Project

1. Open **SQL Server Management Studio (SSMS)**  
2. Open the file:  
   ```
   SMS.sql
   ```  
3. Press **F5** to run the entire script  

The script will:

- Drop the existing database if present  
- Create a fresh new database  
- Build tables, procedures, functions, triggers  
- Insert sample data  
- Provide example test queries  

After execution, you'll have a fully functional Student Management System database.

---

## 🧩 ER Diagram

![ER Diagram](Outputs/SMS ER diagram.png)

---

## 🧪 Sample Queries & Screenshots

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

```
StudentManagementSystem-SQL/
│
├── SMS.sql                      # Full database installer script
├── README.md                    # Documentation
└── Outputs/                     # Screenshots & ER Diagram
    ├── SMS ER diagram.png
    ├── SMS Students.png
    ├── SMS SP.png
    ├── SMS view.png
    ├── SMS Trigger.png
    └── SMS Function.png
```

---

## 🎓 What I Learned

- Database normalization & schema design  
- Implementing PK–FK relationships  
- Writing Stored Procedures  
- Creating Views for reporting  
- Building Functions for calculations  
- Trigger-based auditing  
- Auto-generating sample data  
- Writing professional GitHub documentation  
- Organizing SQL projects cleanly  

---

## ⭐ Support

If you like this project, please ⭐ **star the repository**!  
Your support motivates me to build more projects.

---

## 🤝 Connect With Me

I'm open to collaboration, learning, and SQL/database discussions.  
Feel free to reach out anytime!

