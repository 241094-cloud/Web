const express = require('express');
const router = express.Router();
const controller = require('../controllers/userController');
const auth = require('../middleware/auth');

router.get('/', auth, controller.getUsers);

module.exports = router;