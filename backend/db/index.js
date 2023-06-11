const pg = require("pg")
const { dbUser, dbHost, db, dbPassword, dbPort } = require("../constants")
const { v4: uuidv4 } = require('uuid');
const {Pool} = pg


class Database{

    gettingAll = "SELECT * FROM"
    insert = "INSERT INTO"
    coinTable="coins"
    voteTable="votes"
    bannerTable="banners"
    subscriptionTable="subscription"

    constructor(){
        this.pool = new Pool({
            user: dbUser,
            host: dbHost,
            database: db,
            password: dbPassword,
            port: dbPort,
        })
    }

    getAll(table){
        const sql = `SELECT * FROM ${table}`
        return new Promise( (resolve,reject) =>{
            this.pool.query(sql, (err,res) => {
                if(err) reject(err)
                else resolve(res.rows)
            })
        } )
    }

    addRow(table,data){
        return new Promise( (resolve,reject) => {

            if(table===this.coinTable){
                const sql = `INSERT INTO ${table} ("Address","CoinData") VALUES ($1, $2)`
                const {address} = data
                this.pool.query(sql, [address,JSON.stringify(data)], (err, res)=>{
                    if(err) reject(err)
                    else resolve({...data})
                })
            }else if(table===this.voteTable){
                const sql = `INSERT INTO ${table} ("VoteID","Address","Coin","Time") VALUES ($1, $2, $3, $4)`
                const {address,coin,time} = data
                const id=uuidv4()
                this.pool.query(sql, [id,address,coin,time], (err, res)=>{
                    if(err) reject(err)
                    else resolve({...data,id})
                })
            }else if(table===this.subscriptionTable){
                const sql = `INSERT INTO ${table} ("Id","Email") VALUES ($1, $2)`
                const {email} = data
                const id=uuidv4()
                this.pool.query(sql, [id,email], (err, res)=>{
                    if(err) reject(err)
                    else resolve({...data,id})
                })
            }else{
                reject(`Table "${table}" not available!`)
            }

        } )
    }

    updateRow(table,key,value){
        return new Promise( (resolve,reject) => {

            if(table===this.coinTable){
                const sql = `UPDATE ${table} SET "CoinData" = $1 WHERE "Address" = $2`
                const update = JSON.stringify(value)
                this.pool.query(sql, [update,key], (err, res)=>{
                    if(err) reject(err)
                    else resolve(res.rows)
                })
            }else if (table === this.bannerTable){
                const sql = `UPDATE ${table} SET "Url" = $1, "Link" = $2 WHERE "Name" = $3`
                const {url,link} = value
                this.pool.query(sql, [url,link,key], (err, res)=>{
                    if(err) reject(err)
                    else resolve(res.rows)
                })
            }else{
                reject(`Table "${table}" not available!`)
            }

        } )
    }

    deleteRow(table,address){
        return new Promise( (resolve,reject) => {

            if(table===this.coinTable){
                const sql = `DELETE FROM ${table} WHERE "Address" = $1`
                this.pool.query(sql, [address], (err, res)=>{
                    if(err) reject(err)
                    else resolve(res.rows)
                })
            }else{
                reject(`Table "${table}" not available!`)
            }

        } )
    }



}

module.exports = { Database }