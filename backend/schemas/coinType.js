const Joi = require('joi')

const coinSchema = Joi.object({
    address: Joi.string().required(),
    name: Joi.string().required(),
    symbol: Joi.string().required(),
    chain: Joi.string().required(),
    tags: Joi.string().required(),
    description: Joi.string().required(),
    contact: Joi.string().required(),
    launch: Joi.string().required(),
    website: Joi.string().required(),
    github: Joi.string().required(),
    telegram: Joi.string().required(),
    twitter: Joi.string().required(),
    facebook: Joi.string().required(),
    linkedin: Joi.string().required(),
    promote: Joi.boolean().required(),
    show: Joi.boolean().required(),
})

module.exports = {coinSchema}