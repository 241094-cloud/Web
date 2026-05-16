const express = require('express');
const router = express.Router();

const complaintController = require('../controllers/complaintController');

const auth = require('../middleware/auth');

router.get('/', auth, complaintController.getAllComplaints);

router.get('/my', auth, complaintController.getMyComplaints);

router.post('/', auth, complaintController.createComplaint);

router.put('/:id', auth, complaintController.updateComplaintStatus);

module.exports = router;