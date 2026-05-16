const express = require('express');
const router = express.Router();
const controller = require('../controllers/resourceController');
const auth = require('../middleware/auth');

router.get('/', auth, controller.getResources);
router.post('/allocate', auth, controller.allocateResource);

module.exports = router;