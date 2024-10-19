import express from 'express'

const PORT = process.env.PORT || 3000

const app = express()

app.use(express.json())

app.get("/", (req, res) => {
    console.log("route : /")
    return res.status(200).json("hello world")
})

app.get("/ping", (req, res) => {
    console.log("route : /ping")
    return res.status(200).json("ping")
})

app.listen(PORT, () => {
    console.log(`connect to ${PORT}`)
})

