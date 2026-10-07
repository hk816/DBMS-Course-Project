# MySQL connection setup

The ISIS UI has been wired to the existing MySQL database used by the DBMS project.

## Backend environment
Create `artifacts/api-server/.env` from `.env.example`:

```env
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=YOUR_MYSQL_PASSWORD
MYSQL_DATABASE=healthinsurancedb
```

The backend exposes:
- `GET /api/insurance/state` — reads the project data from MySQL
- `POST /api/insurance/customers` — inserts a customer
- `POST /api/insurance/hospitals` — inserts a hospital
- `POST /api/insurance/claims` — inserts a claim and document
- `DELETE /api/insurance/claims/:id` — deletes a claim
- `POST /api/insurance/evaluate/:id` — calls the MySQL `EvaluateClaim` stored procedure

## Frontend environment
Create `artifacts/isis-health/.env` from `.env.example`.

If the API is on another local port, set:

```env
VITE_API_BASE=http://localhost:3001/api
```

Do not commit the real MySQL password to GitHub.
