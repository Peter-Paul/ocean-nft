const Joi = require('joi')

const voteSchema = Joi.object({
    address: Joi.string().required(),
    coin: Joi.string().required(),
    time: Joi.string().required(),
})

module.exports = {voteSchema}