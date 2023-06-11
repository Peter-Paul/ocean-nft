const Joi = require('joi')

const subscriptionSchema = Joi.object({
    email: Joi.string().required()
})

module.exports = {subscriptionSchema}