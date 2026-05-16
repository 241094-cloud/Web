const { getConnection, oracledb } = require('../config/db');

exports.getResources = async (req, res) => {
  let connection;

  try {
    connection = await getConnection();

    const result = await connection.execute(
      `SELECT * FROM vw_resource_overview`,
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

exports.allocateResource = async (req, res) => {
  let connection;

  try {
    const { resource_id, qty } = req.body;

    connection = await getConnection();

    await connection.execute(
      `BEGIN
          sp_allocate_resource(:resource_id, :qty);
       END;`,
      {
        resource_id,
        qty
      },
      { autoCommit: true }
    );

    res.json({
      success: true,
      message: 'Resource allocated'
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