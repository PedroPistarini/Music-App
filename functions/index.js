const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

admin.initializeApp();
sgMail.setApiKey("YOUR_SENDGRID_API_KEY"); // Substitua com sua chave API do SendGrid

exports.sendTopArtistAndSongEmail = functions.https.onCall(async (data, context) => {
  const { email, topArtist, topMusic } = data;

  const msg = {
    to: email,
    from: "phrpistarini@gmail.com", // Substitua pelo seu email verificado no SendGrid
    subject: "Seu Top Artista e Música no App de Músicas",
    text: `Olá! Aqui estão seus dados mais escutados:\n\nTop Artista: ${topArtist}\nTop Música: ${topMusic}
           \n\nObrigado por usar nosso app!`,
    html: `<p>Olá!</p><p>Aqui estão seus dados mais escutados:</p><ul>
           <li><strong>Top Artista:</strong> ${topArtist}</li>
           <li><strong>Top Música:</strong> ${topMusic}</li></ul>
           <p>Obrigado por usar nosso app!</p>`,
  };

  try {
    await sgMail.send(msg);
    return { success: true };
  } catch (error) {
    console.error("Erro ao enviar email:", error);
    return { success: false, error: error.toString() };
  }
});
