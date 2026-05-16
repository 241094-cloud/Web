const { getConnection, oracledb } = require('../config/db');

exports.getUsers = async (req, res) => {
  let connection;

  try {
    connection = await getConnection();

    const result = await connection.execute(
      `SELECT * FROM vw_user_summary`,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );

    res.json({
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