require('dotenv').config()

const port=process.env.BACKEND_PORT || 5000
const dbUser = process.env.POSTGRES_USER
const dbPassword = process.env.POSTGRES_PASSWORD
const db = process.env.POSTGRES_DB
const dbHost = process.env.POSTGRES_HOST
const dbPort = process.env.POSTGRES_PORT || 5432


module.exports = {
    db,
    dbHost,
    dbPassword,
    dbPort,
    dbUser,
    port
}