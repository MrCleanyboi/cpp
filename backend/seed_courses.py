import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from app.models.learning import Course, Unit, Lesson, IntroLesson, VocabItem
from bson import ObjectId

# Load environment variables from .env file
load_dotenv()

# Database Connection
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "ai_tutor_db")

client = AsyncIOMotorClient(MONGODB_URL)
db = client[DATABASE_NAME]

# ===================================================
#  HELPER: Build IntroLesson from a list of tuples
#  Each tuple: (word, meaning, example, example_translation)
# ===================================================
def _intro(unit_id: str, title: str, items: list) -> IntroLesson:
    return IntroLesson(
        id=f"{unit_id}_intro",
        title=title,
        vocab_items=[VocabItem(word=w, meaning=m, example=e, example_translation=et) for w, m, e, et in items]
    )


# ===================================================
#  GERMAN INTRO LESSONS
# ===================================================
DE_INTROS = {
    "de_u1": _intro("de_u1", "Preview: The Café", [
        ("Ich möchte", "I would like", "Ich möchte einen Kaffee.", "I would like a coffee."),
        ("Die Speisekarte", "The menu", "Die Speisekarte, bitte.", "The menu, please."),
        ("Die Rechnung", "The bill", "Die Rechnung, bitte.", "The bill, please."),
        ("Zucker", "Sugar", "Mit Zucker, bitte.", "With sugar, please."),
        ("Milch", "Milk", "Mit Milch, bitte.", "With milk, please."),
        ("Bitte", "Please", "Einen Tee, bitte.", "A tea, please."),
        ("Danke", "Thank you", "Danke schön!", "Thank you very much!"),
    ]),
    "de_u2": _intro("de_u2", "Preview: Family & Friends", [
        ("Die Mutter", "The mother", "Meine Mutter ist nett.", "My mother is kind."),
        ("Der Vater", "The father", "Mein Vater ist groß.", "My father is tall."),
        ("Der Bruder", "The brother", "Ich habe einen Bruder.", "I have a brother."),
        ("Die Schwester", "The sister", "Meine Schwester heißt Anna.", "My sister is called Anna."),
        ("Die Eltern", "The parents", "Meine Eltern wohnen in Berlin.", "My parents live in Berlin."),
        ("Groß", "Tall / Big", "Mein Bruder ist groß.", "My brother is tall."),
        ("Klein", "Small / Short", "Die Katze ist klein.", "The cat is small."),
    ]),
    "de_u3": _intro("de_u3", "Preview: My Home", [
        ("Die Küche", "The kitchen", "Ich koche in der Küche.", "I cook in the kitchen."),
        ("Das Schlafzimmer", "The bedroom", "Das Schlafzimmer ist groß.", "The bedroom is big."),
        ("Das Wohnzimmer", "The living room", "Wir sitzen im Wohnzimmer.", "We sit in the living room."),
        ("Der Tisch", "The table", "Der Tisch ist neu.", "The table is new."),
        ("Der Stuhl", "The chair", "Der Stuhl ist bequem.", "The chair is comfortable."),
        ("Auf", "On / On top of", "Das Buch liegt auf dem Tisch.", "The book is on the table."),
        ("Unter", "Under / Below", "Die Katze sitzt unter dem Stuhl.", "The cat sits under the chair."),
    ]),
    "de_u4": _intro("de_u4", "Preview: Travel & City", [
        ("Der Zug", "The train", "Der Zug fährt um 9 Uhr ab.", "The train departs at 9 o'clock."),
        ("Das Ticket", "The ticket", "Ich kaufe ein Ticket.", "I buy a ticket."),
        ("Das Hotel", "The hotel", "Das Hotel ist sehr schön.", "The hotel is very beautiful."),
        ("Links", "Left", "Gehen Sie links.", "Go left."),
        ("Rechts", "Right", "Das Hotel ist rechts.", "The hotel is on the right."),
        ("Geradeaus", "Straight ahead", "Gehen Sie geradeaus.", "Go straight ahead."),
        ("Wie weit ist es?", "How far is it?", "Wie weit ist es bis zum Bahnhof?", "How far is it to the station?"),
    ]),
    "de_u5": _intro("de_u5", "Preview: Hobbies & Sports", [
        ("Das Fußball", "Football / Soccer", "Ich spiele Fußball.", "I play football."),
        ("Die Musik", "The music", "Ich höre gern Musik.", "I like listening to music."),
        ("Der Film", "The film / movie", "Wir schauen einen Film.", "We are watching a film."),
        ("Das Wochenende", "The weekend", "Am Wochenende schlafe ich lang.", "On the weekend I sleep in."),
        ("Gern", "Gladly / Like to", "Ich tanze gern.", "I like to dance."),
        ("Spielen", "To play", "Wir spielen Tennis.", "We play tennis."),
        ("Hören", "To listen", "Ich höre Musik.", "I listen to music."),
    ]),
    "de_u6": _intro("de_u6", "Preview: Shopping", [
        ("Das Hemd", "The shirt", "Das Hemd ist blau.", "The shirt is blue."),
        ("Die Hose", "The trousers", "Die Hose ist zu groß.", "The trousers are too big."),
        ("Rot", "Red", "Das Auto ist rot.", "The car is red."),
        ("Blau", "Blue", "Der Himmel ist blau.", "The sky is blue."),
        ("Wie viel kostet das?", "How much does it cost?", "Wie viel kostet das Hemd?", "How much does the shirt cost?"),
        ("Zu teuer", "Too expensive", "Das ist zu teuer.", "That is too expensive."),
        ("Der Markt", "The market", "Ich gehe auf den Markt.", "I go to the market."),
    ]),
    "de_u7": _intro("de_u7", "Preview: Business", [
        ("Die Besprechung", "The meeting", "Die Besprechung beginnt um 10.", "The meeting starts at 10."),
        ("Das Büro", "The office", "Ich arbeite im Büro.", "I work in the office."),
        ("Der Kollege", "The colleague", "Mein Kollege heißt Klaus.", "My colleague is called Klaus."),
        ("Die E-Mail", "The email", "Ich schreibe eine E-Mail.", "I write an email."),
        ("Der Termin", "The appointment", "Ich habe einen Termin.", "I have an appointment."),
        ("Bitte entschuldigen Sie", "Excuse me / I apologise", "Bitte entschuldigen Sie die Verspätung.", "Please excuse the delay."),
    ]),
    "de_u8": _intro("de_u8", "Preview: Media & News", [
        ("Die Nachrichten", "The news", "Ich schaue die Nachrichten.", "I watch the news."),
        ("Die Zeitung", "The newspaper", "Ich lese die Zeitung.", "I read the newspaper."),
        ("Der Computer", "The computer", "Ich arbeite am Computer.", "I work at the computer."),
        ("Soziale Medien", "Social media", "Ich nutze soziale Medien.", "I use social media."),
        ("Die Schlagzeile", "The headline", "Die Schlagzeile ist interessant.", "The headline is interesting."),
        ("Aktuell", "Current / Up-to-date", "Das ist sehr aktuell.", "That is very current."),
    ]),
    "de_u9": _intro("de_u9", "Preview: Environment", [
        ("Der Wald", "The forest", "Der Wald ist grün.", "The forest is green."),
        ("Das Tier", "The animal", "Das Tier lebt im Wald.", "The animal lives in the forest."),
        ("Die Umwelt", "The environment", "Wir müssen die Umwelt schützen.", "We must protect the environment."),
        ("Recyceln", "To recycle", "Ich recycele meinen Müll.", "I recycle my rubbish."),
        ("Die Zukunft", "The future", "Die Zukunft ist wichtig.", "The future is important."),
        ("Meiner Meinung nach", "In my opinion", "Meiner Meinung nach ist das falsch.", "In my opinion, that is wrong."),
    ]),
}

# ===================================================
#  FRENCH INTRO LESSONS
# ===================================================
FR_INTROS = {
    "fr_u1": _intro("fr_u1", "Preview: Le Café", [
        ("Je voudrais", "I would like", "Je voudrais un café.", "I would like a coffee."),
        ("S'il vous plaît", "Please (formal)", "Un thé, s'il vous plaît.", "A tea, please."),
        ("L'addition", "The bill", "L'addition, s'il vous plaît.", "The bill, please."),
        ("Du sucre", "Some sugar", "Avec du sucre, s'il vous plaît.", "With some sugar, please."),
        ("Du lait", "Some milk", "Avec du lait.", "With some milk."),
        ("Merci", "Thank you", "Merci beaucoup!", "Thank you very much!"),
        ("Un café", "A coffee", "Je prends un café.", "I'll have a coffee."),
    ]),
    "fr_u2": _intro("fr_u2", "Preview: Famille", [
        ("La mère", "The mother", "Ma mère est médecin.", "My mother is a doctor."),
        ("Le père", "The father", "Mon père est grand.", "My father is tall."),
        ("Le frère", "The brother", "J'ai un frère.", "I have a brother."),
        ("La sœur", "The sister", "Ma sœur s'appelle Marie.", "My sister is called Marie."),
        ("Les parents", "The parents", "Mes parents vivent à Paris.", "My parents live in Paris."),
        ("Grand(e)", "Tall / Big", "Mon frère est grand.", "My brother is tall."),
        ("Petit(e)", "Small / Short", "Le chat est petit.", "The cat is small."),
    ]),
    "fr_u3": _intro("fr_u3", "Preview: Ma Maison", [
        ("La cuisine", "The kitchen", "Je cuisine dans la cuisine.", "I cook in the kitchen."),
        ("La chambre", "The bedroom", "La chambre est grande.", "The bedroom is big."),
        ("Le salon", "The living room", "Nous regardons la télé au salon.", "We watch TV in the living room."),
        ("La table", "The table", "La table est en bois.", "The table is made of wood."),
        ("La chaise", "The chair", "La chaise est confortable.", "The chair is comfortable."),
        ("Sur", "On / On top of", "Le livre est sur la table.", "The book is on the table."),
        ("Sous", "Under / Below", "Le chat est sous la chaise.", "The cat is under the chair."),
    ]),
    "fr_u4": _intro("fr_u4", "Preview: Voyage à Paris", [
        ("Le métro", "The metro / subway", "Je prends le métro.", "I take the metro."),
        ("Le billet", "The ticket", "J'achète un billet.", "I buy a ticket."),
        ("L'hôtel", "The hotel", "L'hôtel est magnifique.", "The hotel is magnificent."),
        ("À gauche", "To the left", "Tournez à gauche.", "Turn left."),
        ("À droite", "To the right", "L'hôtel est à droite.", "The hotel is on the right."),
        ("Tout droit", "Straight ahead", "Allez tout droit.", "Go straight ahead."),
        ("C'est loin?", "Is it far?", "C'est loin d'ici?", "Is it far from here?"),
    ]),
    "fr_u5": _intro("fr_u5", "Preview: Loisirs", [
        ("Le football", "Football / Soccer", "Je joue au football.", "I play football."),
        ("La musique", "The music", "J'écoute de la musique.", "I listen to music."),
        ("Le cinéma", "The cinema", "On va au cinéma.", "We're going to the cinema."),
        ("Le week-end", "The weekend", "Le week-end, je dors tard.", "On weekends, I sleep in."),
        ("Aimer", "To like / love", "J'aime danser.", "I like to dance."),
        ("Jouer", "To play", "Nous jouons au tennis.", "We play tennis."),
        ("Écouter", "To listen", "J'écoute de la musique.", "I listen to music."),
    ]),
    "fr_u6": _intro("fr_u6", "Preview: Shopping", [
        ("La chemise", "The shirt", "La chemise est bleue.", "The shirt is blue."),
        ("Le pantalon", "The trousers", "Le pantalon est trop grand.", "The trousers are too big."),
        ("Rouge", "Red", "La robe est rouge.", "The dress is red."),
        ("Bleu(e)", "Blue", "Le ciel est bleu.", "The sky is blue."),
        ("Ça coûte combien?", "How much does it cost?", "Ça coûte combien, la chemise?", "How much does the shirt cost?"),
        ("Trop cher / chère", "Too expensive", "C'est trop cher.", "That's too expensive."),
        ("Le marché", "The market", "Je vais au marché.", "I'm going to the market."),
    ]),
    "fr_u7": _intro("fr_u7", "Preview: Vie Pro", [
        ("La réunion", "The meeting", "La réunion commence à 10h.", "The meeting starts at 10."),
        ("Le bureau", "The office", "Je travaille au bureau.", "I work at the office."),
        ("Le collègue", "The colleague", "Mon collègue s'appelle Paul.", "My colleague is called Paul."),
        ("Un e-mail", "An email", "J'écris un e-mail.", "I'm writing an email."),
        ("Un rendez-vous", "An appointment", "J'ai un rendez-vous.", "I have an appointment."),
        ("Excusez-moi", "Excuse me", "Excusez-moi pour le retard.", "Excuse me for the delay."),
    ]),
    "fr_u8": _intro("fr_u8", "Preview: Actualités", [
        ("Les informations", "The news", "Je regarde les informations.", "I watch the news."),
        ("Le journal", "The newspaper", "Je lis le journal.", "I read the newspaper."),
        ("L'ordinateur", "The computer", "Je travaille sur l'ordinateur.", "I work on the computer."),
        ("Les réseaux sociaux", "Social media", "J'utilise les réseaux sociaux.", "I use social media."),
        ("Le titre", "The headline", "Le titre est intéressant.", "The headline is interesting."),
        ("Actuel(le)", "Current", "C'est très actuel.", "That's very current."),
    ]),
    "fr_u9": _intro("fr_u9", "Preview: Environnement", [
        ("La forêt", "The forest", "La forêt est verte.", "The forest is green."),
        ("L'animal", "The animal", "L'animal vit dans la forêt.", "The animal lives in the forest."),
        ("L'environnement", "The environment", "Il faut protéger l'environnement.", "We must protect the environment."),
        ("Recycler", "To recycle", "Je recycle mes déchets.", "I recycle my rubbish."),
        ("L'avenir", "The future", "L'avenir est important.", "The future is important."),
        ("À mon avis", "In my opinion", "À mon avis, c'est faux.", "In my opinion, that is wrong."),
    ]),
}

# ===================================================
#  SPANISH INTRO LESSONS
# ===================================================
ES_INTROS = {
    "es_u1": _intro("es_u1", "Preview: El Restaurante", [
        ("Yo quiero", "I want", "Yo quiero una tapas.", "I want some tapas."),
        ("Por favor", "Please", "El menú, por favor.", "The menu, please."),
        ("La cuenta", "The bill", "La cuenta, por favor.", "The bill, please."),
        ("Azúcar", "Sugar", "Con azúcar, por favor.", "With sugar, please."),
        ("Leche", "Milk", "Con leche.", "With milk."),
        ("Gracias", "Thank you", "¡Muchas gracias!", "Thank you very much!"),
        ("¿Cuánto cuesta?", "How much does it cost?", "¿Cuánto cuesta un café?", "How much does a coffee cost?"),
    ]),
    "es_u2": _intro("es_u2", "Preview: Familia", [
        ("La madre", "The mother", "Mi madre es médica.", "My mother is a doctor."),
        ("El padre", "The father", "Mi padre es alto.", "My father is tall."),
        ("El hermano", "The brother", "Tengo un hermano.", "I have a brother."),
        ("La hermana", "The sister", "Mi hermana se llama Ana.", "My sister is called Ana."),
        ("Los padres", "The parents", "Mis padres viven en Madrid.", "My parents live in Madrid."),
        ("Alto/Alta", "Tall", "Mi hermano es alto.", "My brother is tall."),
        ("Pequeño/Pequeña", "Small", "El gato es pequeño.", "The cat is small."),
    ]),
    "es_u3": _intro("es_u3", "Preview: Mi Casa", [
        ("La cocina", "The kitchen", "Cocino en la cocina.", "I cook in the kitchen."),
        ("El dormitorio", "The bedroom", "El dormitorio es grande.", "The bedroom is big."),
        ("El salón", "The living room", "Vemos la tele en el salón.", "We watch TV in the living room."),
        ("La mesa", "The table", "La mesa es de madera.", "The table is made of wood."),
        ("La silla", "The chair", "La silla es cómoda.", "The chair is comfortable."),
        ("Encima de", "On top of", "El libro está encima de la mesa.", "The book is on the table."),
        ("Debajo de", "Under / Below", "El gato está debajo de la silla.", "The cat is under the chair."),
    ]),
    "es_u4": _intro("es_u4", "Preview: La Ciudad", [
        ("El taxi", "The taxi", "Tomo un taxi.", "I take a taxi."),
        ("El mercado", "The market", "Voy al mercado.", "I go to the market."),
        ("La farmacia", "The pharmacy", "La farmacia está cerca.", "The pharmacy is nearby."),
        ("A la izquierda", "To the left", "Gira a la izquierda.", "Turn left."),
        ("A la derecha", "To the right", "El hotel está a la derecha.", "The hotel is on the right."),
        ("Todo recto", "Straight ahead", "Ve todo recto.", "Go straight ahead."),
        ("¿Dónde está?", "Where is it?", "¿Dónde está la farmacia?", "Where is the pharmacy?"),
    ]),
    "es_u5": _intro("es_u5", "Preview: Hobbies", [
        ("El fútbol", "Football / Soccer", "Juego al fútbol.", "I play football."),
        ("La música", "The music", "Escucho música.", "I listen to music."),
        ("La playa", "The beach", "Voy a la playa.", "I go to the beach."),
        ("El fin de semana", "The weekend", "El fin de semana duermo tarde.", "On weekends I sleep in."),
        ("Gustar", "To like", "Me gusta bailar.", "I like to dance."),
        ("Jugar", "To play", "Jugamos al tenis.", "We play tennis."),
        ("Escuchar", "To listen", "Escucho música.", "I listen to music."),
    ]),
    "es_u6": _intro("es_u6", "Preview: Compras", [
        ("La camisa", "The shirt", "La camisa es azul.", "The shirt is blue."),
        ("El pantalón", "The trousers", "El pantalón es demasiado grande.", "The trousers are too big."),
        ("Rojo/Roja", "Red", "El coche es rojo.", "The car is red."),
        ("Azul", "Blue", "El cielo es azul.", "The sky is blue."),
        ("¿Cuánto cuesta esto?", "How much does this cost?", "¿Cuánto cuesta esta camisa?", "How much does this shirt cost?"),
        ("Demasiado caro/cara", "Too expensive", "Eso es demasiado caro.", "That is too expensive."),
        ("El mercado", "The market", "Voy al mercado.", "I go to the market."),
    ]),
    "es_u7": _intro("es_u7", "Preview: Negocios", [
        ("La reunión", "The meeting", "La reunión empieza a las 10.", "The meeting starts at 10."),
        ("La oficina", "The office", "Trabajo en la oficina.", "I work in the office."),
        ("El colega", "The colleague", "Mi colega se llama Carlos.", "My colleague is called Carlos."),
        ("Un correo electrónico", "An email", "Escribo un correo.", "I'm writing an email."),
        ("Una cita", "An appointment", "Tengo una cita.", "I have an appointment."),
        ("Disculpe", "Excuse me", "Disculpe por el retraso.", "Excuse me for the delay."),
    ]),
    "es_u8": _intro("es_u8", "Preview: Noticias", [
        ("Las noticias", "The news", "Veo las noticias.", "I watch the news."),
        ("El periódico", "The newspaper", "Leo el periódico.", "I read the newspaper."),
        ("El ordenador", "The computer", "Trabajo con el ordenador.", "I work with the computer."),
        ("Las redes sociales", "Social media", "Uso las redes sociales.", "I use social media."),
        ("El titular", "The headline", "El titular es interesante.", "The headline is interesting."),
        ("Actual", "Current", "Es muy actual.", "It's very current."),
    ]),
    "es_u9": _intro("es_u9", "Preview: Medio Ambiente", [
        ("El bosque", "The forest", "El bosque es verde.", "The forest is green."),
        ("El animal", "The animal", "El animal vive en el bosque.", "The animal lives in the forest."),
        ("El medio ambiente", "The environment", "Debemos proteger el medio ambiente.", "We must protect the environment."),
        ("Reciclar", "To recycle", "Reciclo mi basura.", "I recycle my rubbish."),
        ("El futuro", "The future", "El futuro es importante.", "The future is important."),
        ("En mi opinión", "In my opinion", "En mi opinión, eso es incorrecto.", "In my opinion, that is wrong."),
    ]),
}


def create_german_course():
    return Course(
        language_code="de",
        title="German Mastery",
        description="Learn German from scratch to fluency.",
        units=[
            # BEGINNER (Units 1-3)
            Unit(id="de_u1", title="The Café", description="Ordering food and drinks", order=1, intro_lesson=DE_INTROS["de_u1"], lessons=[
                Lesson(id="de_u1_l1", title="Ordering Coffee", description="Basic ordering", type="vocabulary", icon="coffee", order=1, is_locked=False),
                Lesson(id="de_u1_l2", title="The Menu", description="Reading the card", type="vocabulary", icon="restaurant_menu", order=2, is_locked=True),
                Lesson(id="de_u1_l3", title="Paying the Bill", description="Handling money", type="dialogue", icon="receipt_long", order=3, is_locked=True),
            ]),
            Unit(id="de_u2", title="Family & Friends", description="Talking about people", order=2, intro_lesson=DE_INTROS["de_u2"], lessons=[
                Lesson(id="de_u2_l1", title="Family Members", description="Mom, Dad, etc.", type="vocabulary", icon="groups", order=1, is_locked=True),
                Lesson(id="de_u2_l2", title="Describing People", description="Tall, short, nice", type="vocabulary", icon="face", order=2, is_locked=True),
                Lesson(id="de_u2_l3", title="Pets", description="Cats and dogs", type="vocabulary", icon="pets", order=3, is_locked=True),
            ]),
            Unit(id="de_u3", title="My Home", description="Housing and objects", order=3, intro_lesson=DE_INTROS["de_u3"], lessons=[
                Lesson(id="de_u3_l1", title="Rooms", description="Kitchen, Bedroom", type="vocabulary", icon="home", order=1, is_locked=True),
                Lesson(id="de_u3_l2", title="Furniture", description="Table, Chair", type="vocabulary", icon="chair", order=2, is_locked=True),
                Lesson(id="de_u3_l3", title="Where is it?", description="Prepositions", type="vocabulary", icon="search", order=3, is_locked=True),
            ]),

            # INTERMEDIATE (Units 4-6)
            Unit(id="de_u4", title="Travel & City", description="Getting around", order=4, intro_lesson=DE_INTROS["de_u4"], lessons=[
                Lesson(id="de_u4_l1", title="At the Station", description="Buying tickets", type="dialogue", icon="train", order=1, is_locked=True),
                Lesson(id="de_u4_l2", title="Hotel Check-in", description="Booking a room", type="vocabulary", icon="hotel", order=2, is_locked=True),
                Lesson(id="de_u4_l3", title="Directions", description="Left, Right", type="vocabulary", icon="map", order=3, is_locked=True),
            ]),
            Unit(id="de_u5", title="Hobbies & Sports", description="Free time activities", order=5, intro_lesson=DE_INTROS["de_u5"], lessons=[
                Lesson(id="de_u5_l1", title="Sports", description="Football, Tennis", type="vocabulary", icon="sports_soccer", order=1, is_locked=True),
                Lesson(id="de_u5_l2", title="Music & Movies", description="Entertainment", type="vocabulary", icon="movie", order=2, is_locked=True),
                Lesson(id="de_u5_l3", title="Weekend Plans", description="Future tense", type="dialogue", icon="calendar_today", order=3, is_locked=True),
            ]),
            Unit(id="de_u6", title="Shopping", description="Buying things", order=6, intro_lesson=DE_INTROS["de_u6"], lessons=[
                Lesson(id="de_u6_l1", title="Clothing", description="Shirt, Pants", type="vocabulary", icon="checkroom", order=1, is_locked=True),
                Lesson(id="de_u6_l2", title="Colors & Sizes", description="Red, Big", type="vocabulary", icon="palette", order=2, is_locked=True),
                Lesson(id="de_u6_l3", title="At the Market", description="Groceries", type="dialogue", icon="storefront", order=3, is_locked=True),
            ]),

            # ADVANCED (Units 7-9)
            Unit(id="de_u7", title="Business", description="Professional life", order=7, intro_lesson=DE_INTROS["de_u7"], lessons=[
                Lesson(id="de_u7_l1", title="The Meeting", description="Business talk", type="vocabulary", icon="meeting_room", order=1, is_locked=True),
                Lesson(id="de_u7_l2", title="Office Life", description="Supplies, formatting", type="vocabulary", icon="desk", order=2, is_locked=True),
                Lesson(id="de_u7_l3", title="Emails", description="Formal writing", type="vocabulary", icon="email", order=3, is_locked=True),
            ]),
            Unit(id="de_u8", title="Media & News", description="Current events", order=8, intro_lesson=DE_INTROS["de_u8"], lessons=[
                Lesson(id="de_u8_l1", title="The News", description="Headlines", type="vocabulary", icon="newspaper", order=1, is_locked=True),
                Lesson(id="de_u8_l2", title="Technology", description="Computers, AI", type="vocabulary", icon="computer", order=2, is_locked=True),
                Lesson(id="de_u8_l3", title="Social Media", description="Posting, Liking", type="vocabulary", icon="share", order=3, is_locked=True),
            ]),
            Unit(id="de_u9", title="Environment", description="Global issues", order=9, intro_lesson=DE_INTROS["de_u9"], lessons=[
                Lesson(id="de_u9_l1", title="Nature", description="Trees, Animals", type="vocabulary", icon="forest", order=1, is_locked=True),
                Lesson(id="de_u9_l2", title="The Future", description="Predictions", type="vocabulary", icon="public", order=2, is_locked=True),
                Lesson(id="de_u9_l3", title="Debate", description="Expressing opinion", type="dialogue", icon="record_voice_over", order=3, is_locked=True),
            ]),
        ]
    )

def create_french_course():
    return Course(
        language_code="fr",
        title="French Mastery",
        description="Master the language of love.",
        units=[
            # BEGINNER
            Unit(id="fr_u1", title="Le Café", description="Parisian coffee", order=1, intro_lesson=FR_INTROS["fr_u1"], lessons=[
                Lesson(id="fr_u1_l1", title="Un Café", description="Ordering", type="vocabulary", icon="coffee", order=1, is_locked=False),
                Lesson(id="fr_u1_l2", title="Croissants", description="Bakery", type="vocabulary", icon="bakery_dining", order=2, is_locked=True),
                Lesson(id="fr_u1_l3", title="Paying", description="Money", type="dialogue", icon="receipt", order=3, is_locked=True),
            ]),
            Unit(id="fr_u2", title="Famille", description="Family members", order=2, intro_lesson=FR_INTROS["fr_u2"], lessons=[
                Lesson(id="fr_u2_l1", title="Parents", description="Mom & Dad", type="vocabulary", icon="groups", order=1, is_locked=True),
                Lesson(id="fr_u2_l2", title="Siblings", description="Brothers/Sisters", type="vocabulary", icon="face", order=2, is_locked=True),
                Lesson(id="fr_u2_l3", title="Pets", description="Animals", type="vocabulary", icon="pets", order=3, is_locked=True),
            ]),
            Unit(id="fr_u3", title="Ma Maison", description="My House", order=3, intro_lesson=FR_INTROS["fr_u3"], lessons=[
                Lesson(id="fr_u3_l1", title="Rooms", description="Kitchen...", type="vocabulary", icon="home", order=1, is_locked=True),
                Lesson(id="fr_u3_l2", title="Furniture", description="Bed, Table", type="vocabulary", icon="chair", order=2, is_locked=True),
                Lesson(id="fr_u3_l3", title="Garden", description="Flowers", type="vocabulary", icon="deck", order=3, is_locked=True),
            ]),

            # INTERMEDIATE
            Unit(id="fr_u4", title="Voyage à Paris", description="Travel", order=4, intro_lesson=FR_INTROS["fr_u4"], lessons=[
                Lesson(id="fr_u4_l1", title="Le Métro", description="Subway", type="vocabulary", icon="subway", order=1, is_locked=True),
                Lesson(id="fr_u4_l2", title="Musée", description="Culture", type="vocabulary", icon="museum", order=2, is_locked=True),
                Lesson(id="fr_u4_l3", title="Tour Eiffel", description="Sightseeing", type="vocabulary", icon="camera_alt", order=3, is_locked=True),
            ]),
            Unit(id="fr_u5", title="Loisirs", description="Hobbies", order=5, intro_lesson=FR_INTROS["fr_u5"], lessons=[
                Lesson(id="fr_u5_l1", title="Sport", description="Football", type="vocabulary", icon="sports_soccer", order=1, is_locked=True),
                Lesson(id="fr_u5_l2", title="Cinema", description="Movies", type="vocabulary", icon="movie", order=2, is_locked=True),
                Lesson(id="fr_u5_l3", title="Music", description="Concerts", type="vocabulary", icon="music_note", order=3, is_locked=True),
            ]),
            Unit(id="fr_u6", title="Shopping", description="Mode & Style", order=6, intro_lesson=FR_INTROS["fr_u6"], lessons=[
                Lesson(id="fr_u6_l1", title="Vêtements", description="Clothes", type="vocabulary", icon="checkroom", order=1, is_locked=True),
                Lesson(id="fr_u6_l2", title="Couleurs", description="Colors", type="vocabulary", icon="palette", order=2, is_locked=True),
                Lesson(id="fr_u6_l3", title="Boutique", description="Shopping", type="dialogue", icon="shopping_bag", order=3, is_locked=True),
            ]),

            # ADVANCED
            Unit(id="fr_u7", title="Vie Pro", description="Work Life", order=7, intro_lesson=FR_INTROS["fr_u7"], lessons=[
                Lesson(id="fr_u7_l1", title="Entretien", description="Interview", type="vocabulary", icon="work", order=1, is_locked=True),
                Lesson(id="fr_u7_l2", title="Bureau", description="Office", type="vocabulary", icon="desk", order=2, is_locked=True),
                Lesson(id="fr_u7_l3", title="Réunion", description="Meeting", type="vocabulary", icon="meeting_room", order=3, is_locked=True),
            ]),
            Unit(id="fr_u8", title="Actualités", description="News", order=8, intro_lesson=FR_INTROS["fr_u8"], lessons=[
                Lesson(id="fr_u8_l1", title="Journal", description="Newspaper", type="vocabulary", icon="newspaper", order=1, is_locked=True),
                Lesson(id="fr_u8_l2", title="Politique", description="Politics", type="vocabulary", icon="policy", order=2, is_locked=True),
                Lesson(id="fr_u8_l3", title="Internet", description="Web", type="vocabulary", icon="language", order=3, is_locked=True),
            ]),
            Unit(id="fr_u9", title="Environnement", description="Ecology", order=9, intro_lesson=FR_INTROS["fr_u9"], lessons=[
                Lesson(id="fr_u9_l1", title="Nature", description="Forest", type="vocabulary", icon="forest", order=1, is_locked=True),
                Lesson(id="fr_u9_l2", title="Pollution", description="Issues", type="vocabulary", icon="warning", order=2, is_locked=True),
                Lesson(id="fr_u9_l3", title="Recyclage", description="Recycling", type="vocabulary", icon="recycling", order=3, is_locked=True),
            ]),
        ]
    )

def create_spanish_course():
    return Course(
        language_code="es",
        title="Spanish Mastery",
        description="Learn Spanish for travel and life.",
        units=[
            # BEGINNER
            Unit(id="es_u1", title="El Restaurante", description="Ordering food", order=1, intro_lesson=ES_INTROS["es_u1"], lessons=[
                Lesson(id="es_u1_l1", title="Tapas", description="Ordering", type="vocabulary", icon="tapas", order=1, is_locked=False),
                Lesson(id="es_u1_l2", title="Bebidas", description="Drinks", type="vocabulary", icon="wine_bar", order=2, is_locked=True),
                Lesson(id="es_u1_l3", title="La Cuenta", description="Bill", type="dialogue", icon="receipt", order=3, is_locked=True),
            ]),
            Unit(id="es_u2", title="Familia", description="Family", order=2, intro_lesson=ES_INTROS["es_u2"], lessons=[
                Lesson(id="es_u2_l1", title="Padres", description="Parents", type="vocabulary", icon="groups", order=1, is_locked=True),
                Lesson(id="es_u2_l2", title="Hermanos", description="Siblings", type="vocabulary", icon="face", order=2, is_locked=True),
                Lesson(id="es_u2_l3", title="Mascotas", description="Pets", type="vocabulary", icon="pets", order=3, is_locked=True),
            ]),
            Unit(id="es_u3", title="Mi Casa", description="My House", order=3, intro_lesson=ES_INTROS["es_u3"], lessons=[
                Lesson(id="es_u3_l1", title="Cuartos", description="Rooms", type="vocabulary", icon="home", order=1, is_locked=True),
                Lesson(id="es_u3_l2", title="Muebles", description="Furniture", type="vocabulary", icon="chair", order=2, is_locked=True),
                Lesson(id="es_u3_l3", title="Dónde está?", description="Location", type="vocabulary", icon="search", order=3, is_locked=True),
            ]),

            # INTERMEDIATE
            Unit(id="es_u4", title="La Ciudad", description="The City", order=4, intro_lesson=ES_INTROS["es_u4"], lessons=[
                Lesson(id="es_u4_l1", title="Mercado", description="Market", type="vocabulary", icon="storefront", order=1, is_locked=True),
                Lesson(id="es_u4_l2", title="Taxi", description="Transport", type="vocabulary", icon="local_taxi", order=2, is_locked=True),
                Lesson(id="es_u4_l3", title="Emergencia", description="Help", type="vocabulary", icon="emergency", order=3, is_locked=True),
            ]),
            Unit(id="es_u5", title="Hobbies", description="Pasatiempos", order=5, intro_lesson=ES_INTROS["es_u5"], lessons=[
                Lesson(id="es_u5_l1", title="Fútbol", description="Soccer", type="vocabulary", icon="sports_soccer", order=1, is_locked=True),
                Lesson(id="es_u5_l2", title="Música", description="Music", type="vocabulary", icon="music_note", order=2, is_locked=True),
                Lesson(id="es_u5_l3", title="Playa", description="Beach", type="vocabulary", icon="beach_access", order=3, is_locked=True),
            ]),
            Unit(id="es_u6", title="Compras", description="Shopping", order=6, intro_lesson=ES_INTROS["es_u6"], lessons=[
                Lesson(id="es_u6_l1", title="Ropa", description="Clothes", type="vocabulary", icon="checkroom", order=1, is_locked=True),
                Lesson(id="es_u6_l2", title="Colores", description="Colors", type="vocabulary", icon="palette", order=2, is_locked=True),
                Lesson(id="es_u6_l3", title="Pagar", description="Paying", type="dialogue", icon="credit_card", order=3, is_locked=True),
            ]),

            # ADVANCED
            Unit(id="es_u7", title="Negocios", description="Business", order=7, intro_lesson=ES_INTROS["es_u7"], lessons=[
                Lesson(id="es_u7_l1", title="Oficina", description="Office", type="vocabulary", icon="desk", order=1, is_locked=True),
                Lesson(id="es_u7_l2", title="Reunión", description="Meeting", type="vocabulary", icon="meeting_room", order=2, is_locked=True),
                Lesson(id="es_u7_l3", title="Contrato", description="Contract", type="vocabulary", icon="gavel", order=3, is_locked=True),
            ]),
            Unit(id="es_u8", title="Noticias", description="News", order=8, intro_lesson=ES_INTROS["es_u8"], lessons=[
                Lesson(id="es_u8_l1", title="Periódico", description="Newspaper", type="vocabulary", icon="newspaper", order=1, is_locked=True),
                Lesson(id="es_u8_l2", title="Mundo", description="World", type="vocabulary", icon="public", order=2, is_locked=True),
                Lesson(id="es_u8_l3", title="Internet", description="Web", type="vocabulary", icon="language", order=3, is_locked=True),
            ]),
            Unit(id="es_u9", title="Medio Ambiente", description="Environment", order=9, intro_lesson=ES_INTROS["es_u9"], lessons=[
                Lesson(id="es_u9_l1", title="Naturaleza", description="Nature", type="vocabulary", icon="forest", order=1, is_locked=True),
                Lesson(id="es_u9_l2", title="Cambio", description="Change", type="vocabulary", icon="trending_up", order=2, is_locked=True),
                Lesson(id="es_u9_l3", title="Futuro", description="Future", type="dialogue", icon="history_edu", order=3, is_locked=True),
            ]),
        ]
    )

async def seed_courses():
    print("🌱 Seeding courses with VOCAB PREVIEWS (9 Units/Lang, 1 Intro each)...")

    # CLEAR EXISTING COURSES
    print("⚠️ Clearing existing courses...")
    await db.courses.delete_many({})

    # 1. German
    german = create_german_course()
    course_data = german.model_dump(by_alias=True, exclude={"id"})
    await db.courses.insert_one(course_data)
    print("✅ German course created (9 Units + 9 Intro Lessons)")

    # 2. French
    french = create_french_course()
    course_data = french.model_dump(by_alias=True, exclude={"id"})
    await db.courses.insert_one(course_data)
    print("✅ French course created (9 Units + 9 Intro Lessons)")

    # 3. Spanish
    spanish = create_spanish_course()
    course_data = spanish.model_dump(by_alias=True, exclude={"id"})
    await db.courses.insert_one(course_data)
    print("✅ Spanish course created (9 Units + 9 Intro Lessons)")

    print("\n🎉 All 3 courses seeded successfully with 27 intro lessons total!")

if __name__ == "__main__":
    asyncio.run(seed_courses())
