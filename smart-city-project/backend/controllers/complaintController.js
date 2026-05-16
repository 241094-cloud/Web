const { getConnection, oracledb } = require('../config/db');



// ================= CREATE COMPLAINT =================

exports.createComplaint = async (req, res) => {

  let connection;

  try {

    const {
      dept_id,
      area_id,
      title,
      description,
      priority
    } = req.body;

    connection = await getConnection();

    await connection.execute(
      `INSERT INTO COMPLAINTS(
        user_id,
        dept_id,
        area_id,
        title,
        description,
        priority
      ) VALUES(
        :user_id,
        :dept_id,
        :area_id,
        :title,
        :description,
        :priority
      )`,
      {
        user_id: req.user.user_id,
        dept_id,
        area_id,
        title,
        description,
        priority
      },
      { autoCommit: true }
    );

    res.status(201).json({
      success: true,
      message: 'Complaint submitted successfully'
    });

  } catch (err) {

    res.status(500).json({
      success: false,
      message: err.message
    });

  } finally {

    if (connection) {
      await connection.close();
    }

  }

};



// ================= GET ALL COMPLAINTS =================

exports.getAllComplaints = async (req, res) => {

  let connection;

  try {

    connection = await getConnection();

    const result = await connection.execute(
      `SELECT * FROM vw_complaints_full
       ORDER BY created_at DESC`,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );

    res.status(200).json({
      success: true,
      data: result.rows
    });

  } catch (err) {

    res.status(500).json({
      success: false,
      message: err.message
    });

  } finally {

    if (connection) {
      await connection.close();
    }

  }

};



// ================= GET MY COMPLAINTS =================

exports.getMyComplaints = async (req, res) => {

  let connection;

  try {

    connection = await getConnection();

    const result = await connection.execute(
      `SELECT * FROM vw_complaints_full
       WHERE citizen_email = :email`,
      [req.user.email],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );

    res.status(200).json({
      success: true,
      data: result.rows
    });

  } catch (err) {

    res.status(500).json({
      success: false,
      message: err.message
    });

  } finally {

    if (connection) {
      await connection.close();
    }

  }

};



// ================= UPDATE STATUS =================

exports.updateComplaintStatus = async (req, res) => {

  let connection;

  try {

    const { id } = req.params;
    const { status, feedback } = req.body;

    connection = await getConnection();

    await connection.execute(
      `UPDATE COMPLAINTS
       SET comp_status = :status,
           feedback = :feedback,
           updated_at = SYSDATE
       WHERE complaint_id = :id`,
      {
        status,
        feedback,
        id
      },
      { autoCommit: true }
    );

    res.status(200).json({
      success: true,
      message: 'Complaint updated successfully'
    });

  } catch (err) {

    res.status(500).json({
      success: false,
      message: err.message
    });

  } finally {

    if (connection) {
      await connection.close();
    }

  }

};