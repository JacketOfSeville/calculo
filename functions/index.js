const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// [GET] Buscar Alunos
exports.buscarAlunos = functions.https.onRequest(async (req, res) => {
  try {
    const snapshot = await db.collection("alunos").get();
    const alunos = snapshot.docs.map((doc) => ({id: doc.id, ...doc.data()}));
    res.status(200).json(alunos);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// [POST] Adicionar Aluno
exports.gravarAluno = functions.https.onRequest(async (req, res) => {
  try {
    const aluno = req.body;
    await db.collection("alunos").add(aluno);
    res.status(201).json({message: "Aluno adicionado com sucesso"});
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// [DELETE] Remover Aluno
exports.removerAluno = functions.https.onRequest(async (req, res) => {
  try {
    const id = req.query.id;
    await db.collection("alunos").doc(id).delete();
    res.status(200).json({message: "Aluno removido com sucesso"});
  } catch (error) {
    res.status(500).send(error.message);
  }
});
