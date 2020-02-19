const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.myNotification = functions.firestore.document('products/{projectId}').onCreate(doc =>{
    const prod = doc.data();
    const payload = {notification :{
        title: `The ${prod.ProdName} Just Arrived!`,
        text: `${prod.imgurl} Grab the ${prod.ProdName} for only QR. ${prod.ProdCost}! \n\nCheck out the products page for more details.`,
        image: `${prod.imgurl}`
    }};
    admin.messaging().sendToTopic('e-commerce', payload);
})