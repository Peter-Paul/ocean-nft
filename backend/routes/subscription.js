const express = require("express")
let router = express.Router()
const db = require("../db/index.js") 
const { subscriptionSchema } = require("../schemas/subscriptionType.js")
const database = new db.Database()
const table = "subscription"


router.post('/', async (req,res) => {
    try{
        const data = req.body
        const {error} = subscriptionSchema.validate(data)
        if(error){
            res.status(400).json({error})
            return
        }
        let response = await database.addRow(table, data)
        res.status(200).json(response)
    }catch(err){
        res.status(500).json({err})
    }
})

module.exports = router