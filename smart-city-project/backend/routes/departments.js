const express = require('express');
const router = express.Router();

const controller = require('../controllers/deptController');
const auth = require('../middleware/auth');

router.get('/', auth, controller.getDepartments);

router.get('/performance', auth, controller.getDepartmentPerformance);

module.exports = router;