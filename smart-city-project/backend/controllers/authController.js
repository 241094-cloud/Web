const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getConnection, oracledb } = require('../config/db');



// ================= REGISTER =================

exports.register = async (req, res) => {

  let connection;

  try {

    const {
      full_name,
      email,
      password,
      area_id,
      user_role
    } = req.body;

    connection = await getConnection();

    const checkUser = await connection.execute(
      `SELECT * FROM USERS WHERE email = :email`,
      [email.toLowerCase()],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );

    if (checkUser.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await connection.execute(
      `INSERT INTO USERS(
        full_name,
        email,
        password_hash,
        user_role,
        area_id
      ) VALUES(
        :full_name,
        :email,
        :password_hash,
        :user_role,
        :area_id
      )`,
      {
        full_name,
        email: email.toLowerCase(),
        password_hash: hashedPassword,
        user_role: user_role || 'citizen',
        area_id
      },
      { autoCommit: true }
    );

    res.status(201).json({
      success: true,
      message: 'User registered successfully'
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



// ================= LOGIN =================

exports.login = async (req, res) => {

  let connection;

  try {

    const { email, password } = req.body;

    connection = await getConnection();

    const result = await connection.execute(
      `SELECT * FROM USERS
       WHERE email = :email
       AND is_active = 1`,
      [email.toLowerCase()],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );

    if (result.rows.length === 0) {

      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });

    }

    const user = result.rows[0];

    const validPassword = await bcrypt.compare(
      password,
      user.PASSWORD_HASH
    );

    if (!validPassword) {

      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });

    }

    const token = jwt.sign(
      {
        user_id: user.USER_ID,
        email: user.EMAIL,
        role: user.USER_ROLE
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(200).json({
      success: true,
      token,
      user: {
        user_id: user.USER_ID,
        full_name: user.FULL_NAME,
        email: user.EMAIL,
        role: user.USER_ROLE
      }
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