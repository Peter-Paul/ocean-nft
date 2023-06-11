const express = require("express")
let router = express.Router()
const db = require("../db/index.js") 
const { coinSchema } = require("../schemas/coinType.js")
const database = new db.Database()
const table = "coins"

const validPayload = (req,res,next) => { // middleware checking payload
    const {error} = coinSchema.validate(req.body)
    if(error){
        res.status(400).json({error})
        return
    }

    next()
}

router.get('/', async (req,res) => {
    try{
        let response = await database.getAll(table)
        const modResponse = response.map( ({ CoinData }) => { return { ...JSON.parse(CoinData) }} )
        res.status(200).json(modResponse)
    }catch(err){
        res.status(500).json({err})
    }
})

router.post('/', validPayload, async (req,res) => {
    try{
        const data = req.body
        let response = await database.addRow(table, data)
        res.status(200).json(response)
    }catch(err){
        res.status(500).json({err})
    }
})

router.patch('/:address', validPayload, async (req,res) => {
    try{
        let address = req.params.address
        const data = req.body
        await database.updateRow(table,address,data)
        res.status(200).json({status:200})
    }catch(err){
        res.status(500).json({err})
    }
})

router.delete('/:address', async (req,res) => {
    try{
        let address = req.params.address
        await database.deleteRow(table,address)
        res.status(200).json({status:200})
    }catch(err){
        res.status(500).json({err})
    }
})

module.exports = router