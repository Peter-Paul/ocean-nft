const express = require("express")
let router = express.Router()
const { bannerSchema } = require("../schemas/bannerType.js")
const db = require("../db/index.js") 
const database = new db.Database()
const table = "banners"



router.get("/", async (req,res) => {
    try{
       let response = await database.getAll(table)
        res.status(200).json(response)
    }catch(err){
        res.status(500).json({err})
    }
})


router.patch('/', async (req,res) => {
    try{
        const data = req.body
        const {error} = bannerSchema.validate(data)
        if(error){
            res.status(400).json({error})
            return
        }
        let {name,url } = data
        let response = await database.updateRow(table,name,url)
        res.status(200).json(response)

    }catch(err){
        res.status(500).json({err})
    }
})

module.exports = router