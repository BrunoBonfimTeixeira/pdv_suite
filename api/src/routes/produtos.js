router.post("/", async (req, res) => {
  try {
    const { descricao, preco_venda } = req.body;

    if (!descricao || preco_venda == null) {
      return res.status(400).json({ message: "Descrição e preço obrigatórios" });
    }

    const result = await db.query(
      "INSERT INTO produtos (descricao, preco_venda) VALUES ($1,$2) RETURNING id",
      [descricao, preco_venda]
    );

    res.json({ id: result.rows[0].id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao criar produto" });
  }
});

router.patch("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { descricao, preco_venda } = req.body;

    await db.query(
      "UPDATE produtos SET descricao=$1, preco_venda=$2 WHERE id=$3",
      [descricao, preco_venda, id]
    );

    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao atualizar" });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await db.query("DELETE FROM produtos WHERE id=$1", [id]);
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erro ao remover" });
  }
});
