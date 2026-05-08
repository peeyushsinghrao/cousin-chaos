import '../../models/pack.dart';

class PackData {
  static List<Pack> get defaultPacks => [
    _party_starter,
    _mild_but_wild,
    _family_night,
    _spice_it_up,
    _girls_night,
    _guys_unleashed,
  ];

  static final Pack _party_starter = Pack(
    id: 'party_starter',
    title: 'Party Starter',
    description: 'The perfect icebreaker to start the party.',
    emoji: '🎉',
    is18Plus: false,
    prompts: [
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve ever done in public?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever walked into a glass door or wall?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the silliest reason you\'ve ever cried?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Who in this room would you swap lives with for a day?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the last lie you told someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever pretended to like a gift you hated?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s a song you know every word to but are embarrassed about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever blamed someone else for something you did?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s your most embarrassing childhood memory?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever sent a text to the wrong person?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the weirdest thing you\'ve ever eaten on a dare?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever been caught talking to yourself in public?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s your most useless hidden talent?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever laughed so hard you snorted or cried?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the most childish thing you still secretly do?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever tripped and fallen in front of a crowd?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the worst haircut you\'ve ever had?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever forgotten someone\'s name mid-conversation?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the strangest dream you\'ve ever had?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever pretended to know a song and just mumbled along?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s one thing you\'re secretly terrible at?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever accidentally called a teacher mom or dad?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the most embarrassing photo currently on your phone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever laughed at totally the wrong moment in a serious situation?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the worst advice you\'ve ever given someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever eaten food off the floor and said absolutely nothing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s one thing you always lie about on your social profiles?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever cheated at a board or card game?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the most embarrassing autocorrect fail you\'ve had?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever waved back at someone who wasn\'t actually waving at you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most ridiculous thing you\'ve ever bought on impulse?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever eavesdropped on a private conversation?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the dumbest injury you\'ve ever had?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever stayed in the bathroom way too long to avoid someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s one habit you have that you\'d be embarrassed if others knew?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever gotten lost somewhere really obvious?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most dramatic thing you\'ve ever done just for attention?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever rehearsed a whole conversation in your head that never happened?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the worst excuse you\'ve ever made up to get out of something?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever been caught dancing alone in your room?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve ever searched online?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever pretended to be asleep to avoid talking to someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s a show you watch that you\'re genuinely ashamed to admit?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever cried at a commercial or advertisement?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the most ridiculous argument you\'ve ever gotten into?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever lied about being sick to skip work, school, or an event?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the strangest irrational fear you have?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever been genuinely scared by your own reflection?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s one thing you still do from childhood that you\'d never admit?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever had a full conversation with your pet as if it understood?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing voicemail you\'ve ever left someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever gone back to eat food you\'d already thrown away?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the weirdest thing you do when you\'re home alone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever run into something because you were on your phone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s your guiltiest guilty pleasure?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever worn something inside-out all day without noticing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the funniest thing you\'ve done to get out of trouble?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever hidden in a store to avoid someone you knew?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s your most embarrassing physical habit?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the most cringe thing you\'ve ever posted and deleted?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever laughed at your own joke before finishing it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the longest you\'ve worn the same outfit without washing it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever fake-laughed so hard you actually started really laughing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing thing a parent has said in front of your friends?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever sniffed something just to see what it smelled like?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the weirdest thing you\'ve ever said out loud by accident?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever tried to open a push door by pulling it repeatedly?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the most embarrassing nickname you\'ve ever had?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever burned food so badly that you just threw it all away?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What show or movie do you claim to hate but secretly love?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever started a fake cough to avoid talking to someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the pettiest revenge you\'ve ever gotten on someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever Googled yourself and found something embarrassing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the most ridiculous thing you\'ve believed as a kid?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever been caught lying about something completely trivial?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing way you\'ve tried to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever worn mismatched shoes all day without noticing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done at a family gathering?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever had a conversation you completely misunderstood?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the dumbest purchase you\'ve ever regretted immediately?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever sung in public by accident thinking you were alone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s a weird food combination you actually enjoy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever told someone they had something on their face when they didn\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s your most embarrassing moment involving technology?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever tried to take a shortcut that made everything longer?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the weirdest compliment you\'ve ever received?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever been startled so badly you screamed in public?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s the most embarrassing photo your family has of you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever pretended you hadn\'t seen something just to avoid reacting?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing assumption you\'ve ever made about someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever tried to sneak food somewhere you absolutely shouldn\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most dramatic thing you\'ve done after a small inconvenience?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever been caught talking badly about someone who was right behind you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing way you\'ve ever tried to get someone\'s attention?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever accidentally liked an old photo while stalking someone\'s profile?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'What\'s one thing about yourself that you find genuinely funny?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text: 'Have you ever done the wrong thing at a very formal event?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done when you were nervous?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'Have you ever walked into the wrong public toilet and had to walk out?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_t_$i',
        text:
            'What\'s the last embarrassing thing you did that nobody saw — until now?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do your best impression of someone in this room right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Speak in a funny accent for the next 3 full rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do 15 jumping jacks while singing a song at the same time.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Let someone draw on your face with a washable marker.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Sing the chorus of any song out loud right now — no skipping.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do a full 30-second robot dance with absolutely no music.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Call a family member and say I know what you did then hang up immediately.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Let the group post something to your social media right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Talk in complete slow motion for the next 2 full minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Wear your shirt or top backwards for the next 3 rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do your absolute best catwalk across the entire room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let the group style your hair with whatever is available nearby.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Eat a spoonful of hot sauce or the spiciest thing available.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Pretend to be a TikTok influencer doing a tutorial for 1 full minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Say the entire alphabet backwards as fast as you possibly can.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Try to lick your elbow — really try.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Walk like a crab across the entire room without stopping.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Hold the most ridiculous funny face for 30 seconds without laughing.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Text your most recent contact I miss you and show everyone the reply.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Do your absolute best chicken impression for 30 seconds straight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Balance a spoon on your nose for 30 seconds without dropping it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let someone apply lipstick on you while they are fully blindfolded.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do 10 full pushups right now — no excuses no stopping.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Imitate another player until they correctly guess it is them.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Narrate everything you do in a sports announcer voice for 2 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Spin around 10 times and then try to walk in a perfectly straight line.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Read your last 3 sent messages out loud to the whole group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let the group scroll through your phone camera roll for 20 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do your best opera singing voice for 30 seconds straight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Pretend to be a dramatic news reporter and narrate the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Attempt to breakdance for 30 full seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do a dramatic monologue from any movie or show you know.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Wear socks on your hands for the next 2 full rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Talk in rhymes for the next 2 full minutes without stopping.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Sniff every single person\'s hair in the room dramatically.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Attempt the worm all the way across the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Let someone tickle you for 20 seconds — you cannot laugh.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Speak only in the form of questions for the next 2 full rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Pretend to ride an invisible horse around the whole room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Hold a full conversation using only song lyrics.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Attempt to moonwalk all the way across the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let someone draw a face on your hand and use it to speak all next round.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do your absolute best slow-motion run across the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Smell someone\'s feet and give a dramatic detailed reaction.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Try to peel a banana using only your feet.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Stuff marshmallows in your mouth and say your full name clearly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Dance with a broom as your partner for 30 full seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Let someone draw a fake tattoo on your arm however they want.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Try to do a cartwheel — even if it goes badly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Act like a professional chef describing your last meal in detail.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Pretend you are accepting an Oscar and give a full emotional speech.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do your best impression of a baby learning to walk.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let the group give you a silly nickname to use for the rest of the game.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Attempt to juggle 3 items from around the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Sing Happy Birthday in the most dramatic way possible.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do 20 squats while the whole group counts out loud together.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Act out a whole scene from a movie with only sound effects and no words.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Wrap toilet paper around your legs and try to walk in a straight line.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let someone blindfold you and feed you something random from the fridge.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Make animal noises for 1 entire full minute without stopping.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Act like your favourite animal for a full 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Try to do a handstand or cartwheel against the wall.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Speak in a whispering voice for the next 3 full rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Make everyone in the room genuinely laugh in under 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Pretend to be a waiter and take full snack orders from everyone here.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Draw something with your non-dominant hand and group has to guess.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Narrate everything you do for 1 minute like a nature documentary.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Mime a job or profession and let everyone guess what it is.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Do your best DJ impression complete with beatboxing for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Balance a book on your head while walking the full length of the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Pretend to be a dramatic news anchor for a full minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Try to make up a brand new word and use it in 3 different sentences.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Do your best impression of a local TV commercial — full performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let the group give you a completely ridiculous life rule to follow for 5 rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Attempt to beatbox the chorus of any well-known song.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Do a dramatic reading of the last boring message you received.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Act as if everything around you is completely brand new and confusing.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Do your best impression of a grumpy old person telling a very long story.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Sing the next 5 things you say instead of actually speaking them normally.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let someone write a mystery word on your back — you have to guess what it says.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Try to whistle any full recognizable song from start to finish.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Act like a robot for the next 2 complete rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Do your best slow-motion action replay of the last thing you did.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Pretend to be a runway model walking in an imaginary fashion show.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Tell a completely made-up short story using only 3 random words given by the group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let the group pose you like a museum statue — hold it for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Do your absolute best dinosaur impression for a full 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Recite the entire alphabet while doing jumping jacks at the same time.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Pretend the floor around you is lava for the next full 2 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Let someone put temporary stickers all over your face.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Do a freestyle rap about the person directly across from you — 8 lines minimum.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text: 'Act out your whole morning routine in exaggerated slow motion.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Pretend to be a sports commentator narrating a simple everyday action.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Give a 60-second motivational speech about absolutely nothing whatsoever.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let the group rename you something ridiculous for the rest of the game.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Do 30 seconds of your most enthusiastic over-the-top cheerleading.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Pick up any object nearby and give it a full convincing 30-second sales pitch.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Act like a news anchor delivering your very first broadcast for 1 minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Demonstrate how you would teach a complete beginner to do something simple.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'ps_d_$i',
        text:
            'Let the group choreograph a 30-second dance that you must then perform perfectly.',
        type: 'dare',
      ),
    ],
  );

  static final Pack _mild_but_wild = Pack(
    id: 'mild_but_wild',
    title: 'Mild but Wild',
    description: 'A little daring, lot of fun.',
    emoji: '😜',
    is18Plus: true,
    prompts: [
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever had a crush on a close friend\'s sibling?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the biggest secret you\'ve kept from your family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever ghosted someone you actually really liked?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Who was your very first kiss and how was it honestly?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever secretly snooped through someone\'s phone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve ever searched online?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever flirted your way out of trouble?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Who in this room would you most want to go on a date with?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever stalked an ex on social media?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the boldest thing you\'ve ever texted to someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever kissed someone you absolutely shouldn\'t have?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most money you\'ve ever spent trying to impress a crush?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever lied to make yourself sound more interesting?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s your biggest secret turn-on that almost nobody knows?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever had a dream about someone in this room?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the absolute worst date you\'ve ever been on?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever caught feelings for someone you knew you shouldn\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s one thing you\'d do differently in your last relationship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever faked being happy for someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing someone has caught you doing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever had feelings for someone while you were in a relationship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the wildest rumor you\'ve ever spread?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever been rejected — describe the situation honestly?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most daring thing you\'ve done when someone dared you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever sent a risky text you immediately deeply regretted?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s your actual body count? Be completely honest.',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever had a secret crush on a teacher?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the most rebellious thing you\'ve ever done?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever done something naughty in a semi-public place?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most forward or bold thing anyone has ever said to you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever pretended to be drunk to get out of an awkward situation?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s one secret you\'ve never told even your best friend?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever been in a completely secret relationship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the biggest lie you\'ve told that actually somehow worked?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever made a romantic move that completely backfired?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing about your love life right now?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever kissed someone just to make someone else jealous?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the most flirty thing you\'ve done to someone recently?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever been caught staring at someone a bit too long?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s a relationship red flag you knew about but ignored anyway?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever genuinely broken someone\'s heart?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the craziest thing you\'ve done just to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever gone back to an ex you absolutely knew you shouldn\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most awkward situation you\'ve been in with a crush?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever completely faked interest in something just to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve ever done at a party?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever told someone you loved them before you actually meant it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s one physical feature you find attractive that others might find weird?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever drunk-texted someone and deeply regretted it the next day?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing pickup line you\'ve ever actually used?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever liked someone\'s old photo while scrolling their profile?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most recent app on your phone you\'d be embarrassed to show?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever made up a fake name or personality online?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the worst breakup you\'ve ever been through?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever pretended not to like someone to seem cooler?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever cancelled plans for someone and lied about why?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the fastest you\'ve ever fallen for someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever had feelings for someone significantly older or younger?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s your most embarrassing situationship confession?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever been a third wheel and secretly loved it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing about how you act around your crush?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever sent a very questionable late-night text?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most dramatic thing you\'ve done to get someone\'s attention?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever accidentally revealed your feelings when you didn\'t mean to?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing photo you have from a past relationship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever run into an ex in the worst possible timing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most cringe memory you have from your dating history?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever pretended to bump into someone on purpose?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing voicemail or audio message you\'ve ever sent?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever made up a fake emergency to escape a bad date?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s your most embarrassing DM from 2 or more years ago?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever been jealous of a friend\'s relationship and said nothing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done to get noticed by someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever cried over someone who definitely wasn\'t worth your tears?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the biggest relationship mistake you\'ve ever made?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever competed with someone over the same person?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done after being rejected?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever lied about your age to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most forward thing you\'ve said to someone you\'d just met?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever been so nervous around your crush you said something ridiculous?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever confessed feelings and completely regretted it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most awkward almost moment you\'ve had with someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever pretended you were over someone when you absolutely weren\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing dating story involving school or work?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever told a lie in a relationship you never came clean about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most recent text you\'d be embarrassed for anyone here to read?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever liked someone you\'d publicly deny liking if asked?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most dramatic breakup scene you\'ve ever been a part of?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever been someone\'s backup option and realized it too late?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing about how you behave with a crush?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever ghosted someone and felt completely fine about it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve said while flirting?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever been in a love triangle?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s your most regrettable romantic decision of all time?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever had your heart broken and completely fell apart?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'What\'s the most embarrassing text currently in your phone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text: 'Have you ever been the other person in a messy situation?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most spontaneous thing you\'ve done because of attraction?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'Have you ever stayed in something that was bad because the chemistry was good?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_t_$i',
        text:
            'What\'s the most embarrassing thing anyone has ever caught you doing on your phone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Give a dramatic 1-minute speech about why you\'re the best person in this room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let someone go through your text messages for 30 full seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Do your most seductive walk across the entire room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Text your crush something genuinely flirty right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Give a 10-second shoulder massage to the person on your left.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do your best flirty wink at every single person in the room one by one.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group pick your profile picture and change it right now for 30 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Call your last dialed number and say I was thinking about you then hang up.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone read your last 5 full conversations out loud to the group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do a slow dramatic wink directly at the camera — hold the eye contact.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Whisper something genuinely flirty into the ear of the person across from you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let someone go through your search history for 15 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Post a slightly thirsty photo to your story and delete after 5 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Text someone We need to talk and wait for them to respond.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Rate everyone in the room on a flirt scale from 1 to 10 out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone pick a ridiculous new nickname for you to use all game.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Do your best full body roll to any song playing or hummed.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Give the person next to you a dramatic forehead kiss.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Talk in your most seductive voice for the next 2 full rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Confess your biggest current crush to the whole group in detail.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group choose your next social media caption and post it right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Do a dramatic re-enactment of your most embarrassing date.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let someone look at your DMs for 20 full seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Change your relationship status on social media for a minimum of 1 hour.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Tell the most embarrassing story from your entire love life.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let someone write a post on your behalf and actually send it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Dramatically re-enact your very first kiss for the group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Do your best I just woke up and I look amazing selfie pose.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Send a voice message to someone saying I think about you sometimes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let someone make a TikTok or Reel on your phone right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Demonstrate your best good morning text performance in front of everyone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let the group swipe on your dating app for a full 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Post an embarrassing selfie to your story for 10 full minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Attempt a 30-second stand-up comedy routine about your love life.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Tell the group your exact type with brutal complete honesty.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let someone style your hair for a first date look.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Do your best I am in a slow-motion romantic movie walk.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Whisper your most embarrassing nickname to the whole group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let the group rate your flirting style on a scale of 1 to 10.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do your best slow-dance with an invisible partner for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Describe your ideal kiss scenario without using the word kiss once.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let someone look through your liked posts for 20 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Text are you up to someone right now with absolutely no other context.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let the group give you a completely new flirty username.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do a dramatic hair flip and pretend you are in a shampoo commercial.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Let someone pose you for an Instagram photo however they want.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Reenact a romantic movie scene with the person to your right.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Tell the person to your right one genuinely attractive thing about them.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Text your best friend we need to talk and then only send them a meme.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group set up a fake complete dating profile for you right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Demonstrate in detail how you act around someone you find attractive.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group draft and send a message to your last match or DM.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Do your most convincing totally not nervous face and hold it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Give a 2-minute speech about why you are the most dateable person here.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone go through your camera roll and pick the most embarrassing photo.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Text the 5th person in your contacts hey stranger right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Demonstrate how you would introduce yourself to someone you find attractive.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Act out a full breakup scene where you are the one being broken up with.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group pick a song to serenade the person across from you with.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do a full fake first date introduction scene with the person to your left.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Give a detailed description of your celebrity crush to the group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone read the last paragraph of your most recent sent message out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Describe the last person you found genuinely attractive without using their name.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Post a selfie with the caption the group chooses for exactly 15 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do your best subtle flirt at the camera for 20 seconds straight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone send one DM to whoever they choose from your account.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Describe your worst date in full dramatic detail to the whole group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Act out how you would ask someone on a date right now in full detail.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Tell the group 3 things you genuinely find attractive in a person.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone check your Spotify and show everyone your most recent plays.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Describe your love life using only movie titles — minimum 5 titles.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do a fake press interview where the group asks about your dating history for 2 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Send a wink emoji to 3 contacts back to back with absolutely no explanation.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone rewrite your dating bio with their version of brutal honesty.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Try to flirt with an inanimate object convincingly for 30 seconds straight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Give a genuine 10-second hug to the person on your right.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone choose your phone lock screen image for the next 30 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Describe your best quality without mentioning anything physical about yourself.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Read your most cringe DM from 2 or more years ago out loud to everyone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let someone create a skit about your love life in exactly 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text: 'Do a full getting ready for a hot date montage performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Act as if you are nervously asking someone out and the group critiques it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group write 3 possible responses to your last unread message.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Tell everyone the most embarrassing thing someone has done to impress you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do a dramatic reaction to being told I love you for the very first time.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Describe the perfect romantic proposal as if you are doing it right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group create a full relationship resume for you and read it aloud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Tell the room why your last relationship ended with maximum dramatic flair.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do your best impression of yourself when you are trying way too hard to impress.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Act out a scene where you are catching feelings for your absolute best friend.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Give a full detailed breakdown of your type including personality and dealbreakers.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group pick someone in your contacts to call and give a genuine compliment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Demonstrate your first date conversation starter techniques live in front of everyone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Tell the group your most embarrassing love at first sight experience.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do your most convincing interested but completely playing it cool face.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Act out a scene where you accidentally confess your feelings at the worst moment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group narrate your entire love life like a dramatic telenovela.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Send you have been on my mind lately to a contact the group chooses right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Do your best impression of how a romantic comedy character would describe you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'mw_d_$i',
        text:
            'Let the group stage a dramatic intervention about one of your romantic choices.',
        type: 'dare',
      ),
    ],
  );

  static final Pack _family_night = Pack(
    id: 'family_night',
    title: 'Family Night',
    description: 'Safe, funny, and chaotic for the whole family.',
    emoji: '🏠',
    is18Plus: false,
    prompts: [
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the funniest family memory you have?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'Which family member are you most similar to and why?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s one thing you\'d genuinely change about your family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s your all-time favourite family tradition?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the nicest thing a family member has ever done for you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'If you could have any single superpower for just one day what would it be?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most important life lesson your parents ever taught you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What is your very earliest memory you can still clearly remember?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'Who is your personal hero and why exactly?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What is the best gift you\'ve ever received in your life?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the silliest thing you\'ve ever been scared of?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'If you could live absolutely anywhere in the entire world where would it be?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s one dream you\'ve had more than one time?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the most creative thing you\'ve ever made from scratch?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the best piece of advice anyone has ever given you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'If you could trade places with anyone for exactly one day who would you pick?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s your favourite personal memory with a sibling or cousin?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What do you love the absolute most about your family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s your biggest personal achievement that you\'re most proud of?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s one simple thing that always makes you smile no matter what?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the funniest joke you actually know right now?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'If you could eat only one single food forever what would it be?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the weirdest habit that a family member has?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s your absolute favourite thing to do together as a family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most adventurous thing you\'ve ever done in your life?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s your favourite family vacation memory of all time?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'If you could change one rule at home what would that rule be?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What talent do you wish more than anything you could have?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'Who makes you laugh the most in your life and why?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the kindest thing you\'ve ever done for another person?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What is your single most treasured possession right now?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s a skill you genuinely want to learn in your lifetime?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'If you had a whole million dollars right now what would you do with it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'Who is your main role model and what makes them special to you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s one thing you\'re deeply grateful for today?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the funniest thing that\'s ever happened at a family dinner?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What would your perfect dream day look like from start to finish?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'If animals could talk which one do you think would be your best friend?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the best book or movie you\'ve ever experienced and why?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s something important you want to accomplish in the coming year?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What family recipe would you most want to be passed down forever?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'Who was your favourite teacher ever and what made them special?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the best thing about being part of this particular family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'If you could invent absolutely anything what would you create?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the one thing that always brings this family closer together?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the silliest thing you\'ve ever accidentally said out loud?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s your fondest holiday or celebration memory?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'If you could safely time travel where and when would you go first?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the most creative nickname you\'ve ever given someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What quality do you most admire in a specific family member?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s something you secretly wish your family did more of together?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most ridiculous family rule you remember growing up?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s a funny misunderstanding you\'ve had with a family member?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s something kind a family member did that you never told them you noticed?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most embarrassing family story that gets told every year?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s one thing a family member does that secretly drives you crazy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s your favourite family meal of all time?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s one thing you\'d like to tell every person in this room right now?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s a funny thing you believed as a child that turned out to be completely false?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'If this family had a theme song what would it be and why?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most memorable road trip or long journey your family has taken?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s something your family does that you\'ve never seen other families do?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s a childhood game or activity you\'d love to do again with this family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most impressive thing a family member has ever done?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s one thing you\'ve always wanted to ask a family member but haven\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What family memory always makes you laugh even years later?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the most creative excuse a family member has ever used?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the funniest misunderstanding that\'s happened in your family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s your favourite family photo and why does it mean so much?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'If you could rename any family member who would it be and what to?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the most unusual family tradition you have?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s something your family is known for in your community?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the best advice a grandparent or elder has ever given you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What do you want future generations of your family to know?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the funniest prank anyone in your family has ever pulled?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s your family\'s best we\'ll laugh about this later story?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s one family habit you\'ve picked up without even noticing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most generous thing someone in this family has ever done?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s a family secret that is no longer a secret?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most creative solution a family member found to a problem?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s one family memory you wish you could relive?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the best thing that\'s happened to this family in the past year?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s one thing you appreciate about every single person in this room?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s your favourite childhood game you played with family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What family lesson has shaped who you are today?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'If your family made a movie what genre would it be and why?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most touching moment you\'ve ever witnessed in your family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What would you add to make family gatherings even better?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the funniest argument your family has ever had?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What did a family member teach you that you still use today?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s one thing you wish your family talked about more openly?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most adventurous thing you\'d want to do with your whole family?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What family memory brings tears of laughter every single time?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the most creative birthday celebration your family has ever had?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What makes this family truly special and unique?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s the funniest thing a younger family member has ever said?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What talent in your family never gets enough recognition?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text: 'What\'s the best surprise your family has ever given you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What family story gets better and funnier with every single retelling?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_t_$i',
        text:
            'What\'s one thing you love about every single person in this room that you\'ve never said out loud?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do a completely silly dance for everyone in the room right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Give every single person in the room a sincere and genuine compliment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Sing Happy Birthday to the youngest person present right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do your absolute best impression of any family member.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Tell your funniest joke right now and it has to make at least one person laugh.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Walk like a crab all the way across the room and back.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Talk exactly like a robot until your very next turn.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Pretend to ride an invisible horse around the entire room for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do the full chicken dance for a complete 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Speak only in a whisper voice for the next 3 full rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Make every single person in this room laugh in under 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Pretend to be a waiter and take complete snack orders from everyone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Walk around the entire room like a duck all the way around.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Wear socks on both your hands for the next 2 full rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do your best impression of any well-known cartoon character.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Talk in a funny accent until it is your turn again.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Hold a funny face for 30 seconds without laughing even once.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Sing the full chorus of your absolute favourite song out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do your best dance moves using a broom as your dance partner for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let the group choose your pose for a very memorable group photo.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Go to another room and yell I love my family as loud as you possibly can.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Stack household items to build the absolute tallest tower possible.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Give a full piggyback ride to the smallest person in the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Eat a snack with both hands behind your back completely.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Hop all the way around every other player without stopping once.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Try your absolute hardest to lick your own elbow.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Act out your favourite movie scene in complete silence and everyone guesses.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Draw your own self-portrait without ever lifting your pen from the paper.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Make a completely funny face every single time you give an answer this round.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Attempt to spin exactly 5 times and then walk in a perfectly straight line.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do your absolute best superhero landing pose.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Tell a whole 2-minute story using only sound effects and no real words.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Wrap toilet paper around your legs and then try to walk straight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let someone blindfold you and feed you something random from the fridge.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do 10 full pushups while everyone in the room counts out loud together.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Make animal noises for 1 full uninterrupted minute straight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Act completely like your favourite animal for a full 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do a handstand or at least attempt one against the wall.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Try to juggle 3 random household items you find nearby.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Speak only in rhymes for the next 2 full minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Mime a job or profession in complete silence and everyone has to guess.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do your best DJ impression with beatboxing for a full 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Balance a book on your head while walking the entire length of the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Pretend to be a very dramatic news reporter for a full minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Try to make up a brand new word and use it correctly in 3 sentences.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do your best impression of a local TV commercial — full performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let the group give you a completely ridiculous life rule to follow for 5 rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Attempt to beatbox the chorus of any well-known song.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do a dramatic reading of the last boring message you received.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Act as if absolutely everything around you is completely new and confusing.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do your best impression of a grumpy old person telling a very long story.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Sing the next 5 things you say instead of actually speaking them normally.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let someone write a mystery word on your back and you have to guess what it says.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Try to whistle any full recognizable song.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Act like a robot for the next 2 complete rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do your best slow-motion replay of the last thing you did.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Pretend to be a runway model walking in an imaginary fashion show.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Tell a made-up story using only 3 random words the group gives you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let the group pose you like a museum statue and hold it for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do your best dinosaur impression for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Recite the alphabet while doing jumping jacks at the same time.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Pretend the floor is lava for the next 2 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Let someone put stickers all over your face.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do a freestyle rap about the person directly across from you — 8 lines minimum.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Act out your whole morning routine in exaggerated slow motion.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Pretend to be a sports commentator narrating someone\'s simple everyday action.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Give a 60-second motivational speech about absolutely nothing.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let the group rename you something ridiculous for the rest of the game.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do 30 seconds of your most enthusiastic over-the-top cheerleading.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Pick up any object nearby and give it a full convincing 30-second sales pitch.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Act like a news anchor delivering your very first broadcast.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Demonstrate how you would teach a beginner to do something simple.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Narrate your actions like you are the hero of an epic adventure novel.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let someone give you a completely random dance challenge to perform.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do the most over-the-top dramatic sneeze you possibly can.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Act like a professional athlete celebrating after winning the championship.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let the group write a silly short poem about you and read it out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Try to balance a random household object on your chin.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do your best impression of a nature documentary narrator describing someone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Attempt 10 star jumps in complete slow motion.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Let the group teach you a completely made-up silly handshake.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Act out the plot of your favourite movie in exactly 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Do your best impression of how each person in the room walks.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Pretend you are a famous chef describing a recipe for absolutely nothing.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let someone draw an imaginary hat on your head and wear it all round.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Demonstrate the world\'s silliest way to enter a room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Give the most dramatic theatrical bow you possibly can.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Try to say the longest word you know backwards correctly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do your best impression of a robot that is running out of battery.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Act like a game show host presenting a completely made-up prize for 1 minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let the group choreograph a 30-second dance that you then must perform.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Sing a nursery rhyme in your most dramatic operatic singing voice.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Pretend you are teaching a class on how to do something completely ridiculous.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Do your best impression of a very confused tourist asking for directions.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Act like a toddler learning to walk and talk for the next 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Give a heartfelt 30-second acceptance speech for Best Family Member.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let the group write a completely made-up award and present it to you formally.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Demonstrate how you would greet someone you haven\'t seen in 10 years.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text: 'Act out your favourite family memory in complete silent mime.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'fn_d_$i',
        text:
            'Let the group describe a silly situation and you must act it out immediately.',
        type: 'dare',
      ),
    ],
  );

  static final Pack _spice_it_up = Pack(
    id: 'spice_it_up',
    title: 'Spice It Up',
    description: 'For those who want to turn up the heat.',
    emoji: '🔥',
    is18Plus: true,
    prompts: [
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most scandalous thing you\'ve ever done at a party?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever kissed someone you absolutely should not have?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Who in this room do you find the most attractive? Be completely honest.',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the spiciest or most daring text you\'ve ever sent to someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever had a secret rendezvous with someone you weren\'t supposed to see?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most daring place you\'ve ever made out with someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever had genuine feelings for more than one person at the same time?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most risqué thing you\'ve done in a public place?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever sent something intimate that you immediately and deeply regretted?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s something you\'ve done you would never in a million years admit to your parents?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your biggest turn-on that you\'ve never told a single person about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever walked in on someone or been walked in on?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your most embarrassing intimate moment that you can now laugh about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever had a crush on someone significantly older than you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the boldest or most daring move you\'ve ever made on someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your most attractive quality that most people here probably don\'t know about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'If you had to choose one person in this room to kiss right now who would it be?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever done something naughty just to see if you\'d get caught?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the wildest dare you\'ve ever actually completed?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most spontaneous thing you\'ve done to attract someone\'s interest?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever faked confidence to successfully flirt with someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing thing someone has caught you doing completely alone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever genuinely broken someone\'s heart on purpose?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most revealing outfit you\'ve ever worn in public?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been turned down by someone you were completely crazy about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the riskiest decision you\'ve ever made for love or attraction?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the sexiest compliment you\'ve ever received from anyone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s a fantasy you\'d never ever admit to while completely sober?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever snuck someone into a place they definitely shouldn\'t have been?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the longest you\'ve gone without any kind of intimacy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever been attracted to your friend\'s partner?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most romantic thing anyone has ever done specifically for you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your biggest bedroom confession that you\'ve never told anyone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever played strip poker or any similar game?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most daring photo currently on your phone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever gone skinny dipping?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the kiss you regret the most and why?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever been caught in a very compromising position?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s your biggest and most honest situationship confession?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever lied about your experience level to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most unexpected place you\'ve ever felt genuinely attracted to someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever had a one-night stand and do you regret it or not?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s your craziest hookup story in exactly one sentence?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been the other person in a messy complicated situation?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most daring thing you\'ve done while traveling?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever made up a dramatic story about your dating life?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most scandalous secret you know about someone else?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been caught checking someone out by that exact person?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing reason a relationship or situationship ended?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s something you\'d do if you knew with complete certainty nobody would find out?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most daring thing you\'ve done on a first date?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been attracted to someone you genuinely knew was wrong for you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most outrageous rumor about your love life that is actually true?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been in a friends-with-benefits situation? How did it end?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most intimate thing you\'ve done with someone you barely knew?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever used your looks or charm to get something you wanted?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most memorable kiss you\'ve ever had and why?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever had feelings develop for someone who was completely off limits?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing moment involving attraction in public?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever done something specifically because someone dared you to and wished you hadn\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing thing that\'s happened to you on a date?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever kissed a complete stranger?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the biggest lie you\'ve told in a romantic context?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever been attracted to someone you only met online?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your most honest opinion of every person in this room\'s attractiveness?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing place you\'ve ever cried over someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever liked someone back after they stopped liking you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever done something completely out of character to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most forward thing you\'ve done that actually worked perfectly?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever had a secret admirer and did you like them back?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your most honest review of your own romantic track record?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most daring thing you\'d do to win over someone you really wanted?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever said I love you knowing you didn\'t completely mean it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done in the name of attraction?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever caught feelings for someone in a way you\'ve never been able to explain?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most daring scenario you\'ve ever actually agreed to?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s something about your romantic life you\'d never post on social media?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been someone\'s experiment or practice relationship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done when you had too much to drink?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your most honest description of your biggest romantic weakness?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever done something intimate in a car?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most forward or bold flirt you\'ve sent that completely worked?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your most embarrassing story involving attraction and technology?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been turned on by someone at completely the wrong moment?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s something about your past romantic life that still makes you cringe?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been too embarrassed to tell someone you liked them?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most unexpected type of person you\'ve ever been attracted to?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever done something daring in a hotel room?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your most honest confession about your physical preferences?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever completely misread romantic signals and been humiliated?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever done something completely impulsive because of attraction?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s your biggest romantic regret that you still think about sometimes?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever been in a love triangle and what did you do?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'What\'s the most daring thing you\'ve ever agreed to on a dare?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve ever confessed to a partner?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text: 'Have you ever gone back to someone purely out of loneliness?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most outrageous dare involving attraction you\'ve ever completed?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever been in a secret crush situation at work or school?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'Have you ever carried feelings for someone longer than you\'ve admitted to anyone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_t_$i',
        text:
            'What\'s the most embarrassing thing about your romantic life right now?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Send a genuinely flirty text to the last person you texted right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone look at your dating app profile for 30 full seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do your most convincingly seductive dance for exactly 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Whisper something genuinely flirty into the ear of the person across from you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone read your last 3 flirtatious conversations out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Give the person on your left a 10-second shoulder massage.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Call your most recent ex and say I\'ve been thinking about you then hang up.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Post a noticeably risqué photo to your story for exactly 5 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group draft and actually send a message to your last flirty DM.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Do a full dramatic lap dance performance for an empty chair.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Give a sensual back massage to whoever the whole group picks.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Lick your finger and lightly touch someone\'s cheek.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone apply lipstick on you while they are fully blindfolded.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Let the group read your last 10 DMs — all of them.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Demonstrate your absolute best come hither look and hold it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Send your most embarrassing selfie to a random contact right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Let the group scroll through your liked posts for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Play 7 seconds of heaven with the person to your right — just staring intensely.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Tell the group your current crush in complete honest detail.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone else write and post your next Instagram caption right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do your absolute best bedroom eyes and hold them for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Let the group look through your most recent search history.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Describe your ideal night in explicit but completely tasteful detail.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do a full dramatic body roll while holding direct eye contact with someone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Confess the last person you had a dream about to the whole group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Let someone draw something meaningful on your inner arm.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Text you looked really good last time I saw you to someone in your contacts.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Do a full runway catwalk with your most convincing model walk.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group pick someone in your contacts to text what are you doing tonight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Describe the most attractive person you\'ve ever met without using their name.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Twerk to a 30-second clip of any song the group picks right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone blindfold you and make you guess who touches your hand.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Give a dramatic 1-minute speech on exactly why you are irresistible.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Act out a romantic movie scene with the person to your right.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Let the group create your situationship era playlist name.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Call someone and ask them what would you honestly rate me out of 10.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone pose you for an imaginary glossy magazine cover photo.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Ask the room who would date me if they absolutely had to — everyone must answer.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Let the group pick what you wear for your very next dare turn.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Reenact your first ever romantic scene as dramatically as possible.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do a fake press interview where the group asks about your dating history for 2 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Send a wink emoji to 3 contacts back to back with zero explanation.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone rewrite your dating bio with their version of brutal honesty.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Try to flirt with an inanimate object convincingly for 30 full seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Give a genuine 10-second hug to the person on your right.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone choose your phone lock screen for the next 30 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Describe your best quality without mentioning anything physical about yourself.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Read your most cringe DM from 2 or more years ago out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone create a skit about your love life in exactly 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Do a full dramatic getting ready for a hot date performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Act as if you are nervously asking someone out and the group critiques your technique.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group write 3 possible responses to your last unread message.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Tell everyone the most embarrassing thing someone has done to impress you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do a dramatic reaction to hearing I love you for the very first time.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Describe the perfect romantic proposal as if you are proposing right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group create a full relationship resume for you and read it aloud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Tell the room why your last relationship ended with maximum dramatic flair.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do your best impression of yourself when you are trying way too hard to impress.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Act out a scene where you are catching feelings for your absolute best friend.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Give a full detailed breakdown of your type including personality and dealbreakers.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group pick someone in your contacts to call and compliment sincerely.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Demonstrate your first date conversation starter techniques live.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone pick any photo from your camera roll to post for 10 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Tell the group your most embarrassing love at first sight experience.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do your most convincing interested but completely playing it cool face.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Act out a scene where you accidentally confess your feelings at the worst moment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group narrate your entire love life like a dramatic telenovela.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Send you\'ve been on my mind lately to a contact the group chooses.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do your best impression of how a romantic comedy character would describe you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group stage a dramatic intervention about your romantic choices.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Act out your version of the perfect first kiss scene for the group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Let someone describe your type as they honestly see it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do a dramatic reading of the most embarrassing text you\'ve ever received.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group create a completely made-up celebrity romance for you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Describe your ideal partner in full complete detail to the group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Act out how you would handle being stood up on a first date.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group roleplay as your exes giving a character witness statement.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Give a 1-minute speech titled Why I Deserve To Be Loved with complete conviction.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Act out the scene right before your most embarrassing romantic moment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group vote on your most likely romantic villain arc scenario.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Demonstrate how you act when you are falling for someone and the group rates it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone pick a song that describes your love life and you must perform it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Act out getting your heart broken in complete dramatic slow motion.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Give the group your most honest hard lessons I have learned from dating speech.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group create a dating profile for you and read it out loud to everyone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Perform your version of the I was wrong and I am sorry speech dramatically.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Act out your whole personality changing when your crush walks into the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group give you a complete romantic makeover — new name new vibe.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do a dramatic reading of your ideal love story in 60 seconds maximum romance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Tell the group your most honest opinion about your own attractiveness.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Act out the most dramatic version of the one that got away moment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group write a fake love letter to you and read it out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Demonstrate all the different ways you flirt and the group votes on which works.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Tell the group the most romantic thing you\'ve ever done for someone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let someone pick a ridiculously dramatic romantic song to serenade the group with.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text: 'Act out your most convincing I am not jealous performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group create the most dramatic possible ending to your love life story.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Tell the group the most embarrassing thing you\'ve done because of attraction.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Do a dramatic performance of getting butterflies when you see your crush.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'su_d_$i',
        text:
            'Let the group design your villain origin story involving love and attraction.',
        type: 'dare',
      ),
    ],
  );

  static final Pack _girls_night = Pack(
    id: 'girls_night',
    title: 'Girls Night Out',
    description: 'Spilling tea and causing chaos.',
    emoji: '💅',
    is18Plus: true,
    prompts: [
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Which girl here do you honestly think is most naturally attractive?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s the most tea you\'ve ever spilled about someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever intentionally stolen a friend\'s crush?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s the most dramatic thing you\'ve ever done for a guy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Who\'s the messiest friend you have and what\'s the most dramatic thing they\'ve done?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done to impress a man?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever cried over someone who genuinely wasn\'t worth a single tear?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Who was your absolute worst date ever — describe exactly what happened?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the biggest friendship betrayal you\'ve ever personally experienced?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever secretly liked your friend\'s partner?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s the pettiest thing you\'ve ever done after a breakup?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s your most embarrassing personal glow-up story?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever ghosted a perfectly good guy for no real valid reason?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most ridiculous thing you\'ve bought to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Who\'s the best kisser you\'ve ever experienced — describe them without names?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s the wildest DM you\'ve ever received from anyone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever talked badly about a friend behind their back?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s your most embarrassing girl moment of all time?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever been part of a girls group chat that turned completely messy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most savage thing you\'ve ever done to get back at an ex?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s one secret you\'ve never told any of your girlfriends?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever pretended to like someone\'s outfit when you really didn\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most dramatic fight you\'ve had with a female friend?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever blocked someone and then unblocked them multiple times?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing your body has done at the worst possible moment?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most cringe thing you\'ve ever posted and then immediately deleted?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever competed against a friend over the same person?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s your most embarrassing morning-after story?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s the worst dating advice you\'ve ever followed?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Who\'s your biggest what on earth was I thinking in terms of past relationships?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever done something completely crazy just to get a guy\'s attention?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most passive-aggressive thing you\'ve ever done to someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever read someone\'s messages without them ever knowing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s your guilty pleasure that you\'d never admit outside of girls night?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever been embarrassingly and unhealthily obsessed with someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most dramatic rumor that actually turned out to be completely true?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s something you\'d only ever admit when the drinks are flowing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most completely unhinged thing a guy has ever done for you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever made up a fake emergency just to escape from a terrible date?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve ever said trying to sound cool?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever been genuinely jealous of a girlfriend\'s relationship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the cattiest thought you\'ve ever had about someone else?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s your most absolutely chaotic going out story?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever pretended to be someone completely different online?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s one thing all of your exes have in common?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever dated someone purely because they were attractive?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most ridiculous thing you\'ve ever genuinely cried about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever purposely made someone jealous and did it actually work?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s your biggest he\'s not worth it but confession?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing currently in your camera roll?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s the shadiest thing you\'ve ever done in a friendship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done on a night out?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever said you were fine when you were absolutely not fine?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s the most dramatic thing you\'ve done for social media?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever pretended to like someone\'s boyfriend just to keep the peace?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s the worst thing you\'ve ever said in a group chat?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever flirted with someone\'s partner just to see if you could?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s your most embarrassing fashion choice you still think about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever told a secret you were explicitly trusted to keep?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most chaotic rumor about you that was unfortunately true?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever acted like you didn\'t care when you were absolutely devastated?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done to avoid someone you knew?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s your most honest confession about comparing yourself to other girls?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever been genuinely mean to someone and felt completely fine about it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most unhinged thing you\'ve done while upset over a guy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing about your past social media self?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever liked someone purely for the drama they brought?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s your most honest confession about your friendship priorities?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever said I\'m not like other girls and fully believed it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing reason you\'ve ended a friendship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever gone through your partner\'s or crush\'s phone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the biggest secret you\'ve kept from your best girlfriend?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most dramatic thing you\'ve done to get over someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever cried in a public bathroom over a boy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s your most embarrassing reaction to being rejected?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever been the messy friend in a group situation?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing about how you handle jealousy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever written something about someone you never actually sent?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the worst thing you\'ve ever done in the name of being petty?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever sabotaged something for yourself out of fear?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s your most honest confession about female friendships overall?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever pretended a relationship was better than it actually was?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most dramatic text exchange you\'ve ever been involved in?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever been caught lying to a girlfriend?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s your most embarrassing main character moment that went completely wrong?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever done something solely for the story?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the realest thing you\'ve ever said to someone who didn\'t want to hear it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever been jealous of someone\'s life and never admitted it to anyone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s a girl code rule you\'ve broken?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever talked yourself into liking someone who was completely wrong for you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'Have you ever sent a screenshot to the wrong person?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve said in a voice note?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s your most dramatic overreaction to something completely small?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever done something specifically to make an ex jealous on social media?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing about your current situationship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text: 'What\'s your most honest hot take about relationships?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever done something completely unhinged and would honestly do it again?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing about how you act when you really like someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'Have you ever kept a friendship going way too long purely out of habit?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve ever sent to the wrong person?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do your absolute best catwalk across the full length of the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Rate every single person\'s outfit in the room with complete honesty and no filter.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do a full proper TikTok-style dance right now — full commitment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Give the person next to you a mini makeover using whatever is available.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Tell the entire group your biggest girl secret right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Call the last guy you texted and say I was literally just thinking about you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group go through your dating app for a full 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Post an unfiltered and completely real selfie to your story right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do a full dramatic main character walking into the room entrance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Reenact your most embarrassing dating moment with full drama.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group write a complete text to send to a guy you like.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do your most convincing dramatic breakup monologue.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group pick your very next profile photo.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do a runway walk in the most ridiculous possible way imaginable.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Read your most embarrassing text from the last month completely out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Demonstrate your absolute best flirting technique on someone right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group give you a new hairstyle using whatever is available.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Act out a full dramatic Karen moment as convincingly as possible.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Give a full convincing speech about why you are the main character of your life.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do your best impression of any reality TV star.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Attempt a full British accent and maintain it for the next 3 complete rounds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group roast your fashion choices for a full minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Dance like absolutely nobody is watching for 45 uninterrupted seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do a full dramatic I am the villain in this story monologue.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group rate your dancing on a scale of 1 to 10 while you perform.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Tell the room your most absolutely chaotic night out story.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Send a u up text to someone with no context or explanation whatsoever.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Recreate your favourite celebrity pose and nail it perfectly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let someone else apply your makeup for exactly 2 minutes.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Roast the person to your left lovingly but with brutal honesty.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do your best full slay queen entrance like you completely own the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Attempt the highest note you possibly can from your favourite song.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group choose and actually post your next social media status.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Demonstrate exactly how you act when you are obviously flirting.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do the most dramatic evil villain laugh you possibly can.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Describe the person you\'d least likely date in this room and why honestly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group write a girls night confessional post on your behalf.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Act out your most cringe first date moment in full detail.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group rate your celebrity lookalike honestly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Tell everyone your most genuinely embarrassing crush confession.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do your absolute best I am completely unbothered face for 30 straight seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let someone do your hair as if preparing you for a red carpet event.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Reenact your last argument with complete and full dramatic flair.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Describe your dream man to the group in specific honest detail.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group roleplay as your personal hype squad and fully pump you up.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do a completely convincing girl boss speech for 1 full minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let someone read your most embarrassing DMs out loud to the group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Act out getting ready for a night out and arriving at the club in 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Share your most absolutely unhinged shower thought with the group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Attempt a full split or give it your absolute best shot.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do a complete dramatic slow-motion walk across the entire room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group narrate your life as a dramatic documentary.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Attempt to apply lipstick perfectly while the group tries to distract you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do your best impression of each person in the room\'s voice one by one.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group choreograph a 30-second dance that you must then perform.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Perform a dramatic reading of the last conversation in your group chat.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let someone give you a complete makeover using only what is in their bag.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do a dramatic acceptance speech for Most Iconic Friend.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Act out a scene where you are meeting your idol for the very first time.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group decide your most likely villain origin story.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Perform your best impression of a beauty influencer reviewing a product.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Tell the group your most honest hot take about relationships right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let someone write a fake celebrity profile for you and read it out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do your best impression of a dramatic TV show character for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Attempt to recreate a famous movie or music video scene completely solo.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group pick a category and you have to rank everyone in the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do a fake sponsored post about any product currently in the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Tell the group who you think is most likely to end up famous and exactly why.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let someone else tell the group your most embarrassing story.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Act out getting ignored on read for a full 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do your best impression of a first-time content creator.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group pick a scene and you have to act it out immediately.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Perform a full dramatic reading of any message currently in your phone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do your best slo-mo hair flip and hold the pose dramatically.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group give you a completely new social media persona.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Act out your version of the perfect hot girl summer day.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Tell the group your most honest and controversial girl opinion.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do your best impression of someone in the group getting ready for a night out.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group write a dramatic monologue for you to deliver.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Act out exactly what you\'d do if you saw your ex out tonight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Demonstrate your say yes to everything mode for a full 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Tell the group your most embarrassing fashion era with full detail.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group cast you in a reality TV show and pick your exact role.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do your most convincing I am totally over it performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let someone post a story on your behalf and the group decides what it says.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Act out your most iconic moment in friendship history.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Give a 1-minute speech titled The Real Me with full vulnerability.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group create your character arc from start to right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Do your best impression of getting completely ignored at a bar.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Tell the group your most embarrassing public meltdown story.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group assign everyone a character in a reality show version of tonight.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Act out meeting your future self — what does she tell you?',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Demonstrate how you\'d react to finding out a friend spilled your secret.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Let the group vote on your most chaotic era.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Tell the group something you\'d want your younger self to know.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Do a full impression of the messy friend archetype for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group write your girls night testimonial and read it aloud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text: 'Act out the most dramatic version of waking up with no regrets.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Tell the group the funniest thing that\'s ever happened in a girls group chat.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gn_d_$i',
        text:
            'Let the group create the most dramatic possible version of your love life story.',
        type: 'dare',
      ),
    ],
  );

  static final Pack _guys_unleashed = Pack(
    id: 'guys_unleashed',
    title: 'Guys Unleashed',
    description: 'Savage, funny, and no holding back.',
    emoji: '💪',
    is18Plus: true,
    prompts: [
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the bro code rule you\'ve actually broken?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever genuinely cried watching a movie — which one?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve done to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Who would you call at 3am if you were in serious real trouble?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s something you\'d absolutely never admit to your guy friends normally?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever been in a real physical fight — who actually won?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing your mom has said in front of your friends?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever secretly liked a close friend\'s girlfriend?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the pettiest reason you\'ve ever ended a friendship?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most dramatic thing you\'ve done after being rejected?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever pretended to be tougher or more confident than you actually are?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the most money you\'ve spent trying to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever stalked someone obsessively on social media?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s your worst trying to be cool complete failure?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever lost a fight that you started?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing a girl has ever caught you doing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever lied about your actual age to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the worst date you\'ve ever been on?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever been rejected and handled it really badly?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the most embarrassing thing you\'ve done while drunk?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s your biggest personal insecurity that you never talk about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been firmly friend-zoned by someone you genuinely liked?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the most unmanly thing you secretly love doing?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever completely chickened out of something you said you\'d do?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most ridiculous thing you\'ve lied about to impress a girl?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever sent a risky message and had to awkwardly play it off?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s your most embarrassing athletic or sports fail?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever cried over a girl without ever letting her know?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the worst nickname you\'ve ever been given?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been caught secretly checking yourself out in a mirror?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most awkward situation you\'ve ever been in with a girl?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever worn something embarrassing just to try to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the biggest personal L you\'ve ever taken in front of the guys?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been genuinely scared in a situation you pretended to handle fine?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s something you do in complete secret that you\'d never admit to anyone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been turned down in the most embarrassing way possible?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing photo of you that someone else still has?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been genuinely intimidated by someone you\'d never admit?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s your most regrettable tattoo or dramatic haircut decision?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever pretended to understand something you had absolutely no clue about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the manliest thing you\'ve done that went completely and totally wrong?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever backed out of a dare purely out of fear?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s your most embarrassing tough-guy fail ever?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever gotten hopelessly lost and refused to ask for directions?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s something your mom knows about you that your friends definitely don\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever been caught crying and had to quickly explain it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing voicemail or text you\'ve ever sent?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever pretended to be sick purely to avoid a challenge?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s one thing about yourself you\'re genuinely working hard to improve?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing your friends know about your romantic history?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever cried at something you\'d absolutely deny crying at?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s your honest opinion of your own rizz level?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever made a bet about a girl and completely regretted it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve accidentally texted your mom?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever pretended to know how to do something you had no idea about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever gotten genuinely emotional about a sports result?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s your most embarrassing driving story?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever lied about a personal achievement to look more impressive?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the most childish thing you still secretly enjoy?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever been utterly roasted by someone younger than you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s your most unmanly fear that you\'ve never told anyone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever gotten a bad tattoo and what is it?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s your most embarrassing karaoke experience?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever told someone you loved them too early?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing way you\'ve tried to impress someone\'s parents?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever gotten in trouble specifically trying to look tough?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the most ridiculous bet you\'ve ever made with friends?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever been completely starstruck meeting someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s your most embarrassing social media post from your past?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever completely failed to parallel park in front of people?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'What\'s the most embarrassing thing about your gaming history?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever fallen asleep somewhere you absolutely shouldn\'t have?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing you\'ve said trying to sound smart?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever bought something expensive specifically to impress someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s your most embarrassing story involving cooking for someone?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been frozen with nervousness in front of someone you liked?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most ridiculous argument you\'ve ever gotten into with a stranger?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever been outsmarted by someone much younger than you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing about how you handle conflict?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever pretended to like a sport or team just to fit in?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been the worst player in a group sport and pretended otherwise?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s your most embarrassing drunk confession that you\'ve made?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever had a complete public meltdown over something trivial?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing about how you handle rejection?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been caught exaggerating a story about yourself significantly?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s something about yourself you still struggle to be completely honest about?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been completely humiliated in a way that still stings?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s your most honest confession about your own confidence level?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text: 'Have you ever completely misread a situation with a girl?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s your most embarrassing performance in a competitive situation?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever pretended a girl was just a friend when she absolutely wasn\'t?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most sensitive topic that secretly really gets to you?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been genuinely terrified of something completely trivial?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever been caught not knowing something everyone assumed you knew?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'Have you ever pretended to find something funny that you completely didn\'t get?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing text exchange you\'ve had this entire year?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most ridiculous thing you\'ve done on a dare that you now regret?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s your most embarrassing reaction to being genuinely scared?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the one thing about yourself that you\'d most like to change?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_t_$i',
        text:
            'What\'s the most embarrassing thing about your love life that your mates know?',
        type: 'truth',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do 30 consecutive pushups right now — no stopping no excuses.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group style your hair however they want using whatever is available.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Text your mom I love you with 5 heart emojis right now and show everyone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do the most dramatic superhero landing pose you possibly can.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Roast the person to your left as hard as you can in exactly 1 minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your best impression of a famous athlete celebrating a big win.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let the group judge your flex pose for a full 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Call someone and do your best fake foreign accent for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let someone read your most embarrassing text message out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Challenge someone in the room to an arm wrestle right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Attempt to do the full splits — give it everything you have.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let the group write a complete text to send to your crush.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do the most dramatic WWE-style entrance into the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Attempt to beatbox for a full 45 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do 20 full squats while the whole group counts out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Eat a raw egg or the absolute spiciest thing available without flinching.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let someone draw a fake tattoo on your arm however they want.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Act out a scene from your favourite action movie completely solo.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group pick the most ridiculous dance you have to do and do it perfectly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Attempt a full dramatic slow-motion run all the way across the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group give you a new ridiculous gangster nickname to use all game.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Call your dad and say you urgently need advice on impressing someone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let the group take the most embarrassing possible photo of you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do your best gym bro protein shake speech for a full 1 minute.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Pretend to be a boxing announcer introducing yourself for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Roast your own outfit for a complete 1 minute like a fashion critic.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do your absolute best impression of your own dad.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let someone shave off a very tiny bit of your eyebrow if you dare.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do a full music video body roll routine to a pop song.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group create your video game character and describe all your stats.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Reenact getting rejected and handling it terribly for the whole group.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Attempt to moonwalk all the way across the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let the group rate your rizz honestly on a scale of 1 to 10.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Demonstrate exactly how you act when a girl gives you attention.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do your best stand-up comedy bit for exactly 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group pick a genuinely embarrassing song you must fully dance to.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Text a random contact you\'re lowkey my favourite person not gonna lie.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do your best just woke up and feel amazing performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let someone look at your search history for a full 15 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Attempt to freestyle rap about the person directly across from you — 8 lines.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let the group design your complete villain origin story.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do a dramatic rom-com running to catch someone at the airport scene.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group read your last message from your best mate out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your best impression of every single player in the room back to back.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Pretend you are accepting an award and thank specific people in the room.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group interview you for the job of professional fun person.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do 10 burpees without stopping while the group times you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Let someone put full makeup on one entire side of your face.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Attempt to twerk — the group rates your performance honestly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Stand on one leg and tell your most embarrassing story without wobbling.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your absolute best impression of a coach giving a locker room speech.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group pick a sports challenge you must attempt right now.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Perform a dramatic sports commentator monologue entirely about yourself.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do 30 seconds of your best cheerleading performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let someone read every notification on your phone for 30 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do a dramatic slow-motion replay of your greatest imaginary sports moment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Demonstrate your best technique for impressing someone at a party.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group narrate your life as a dramatic sports documentary.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Act out your most embarrassing trying to be smooth moment.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do a full 2-minute press conference about absolutely nothing important.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group cast you as a movie character and perform one scene.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Attempt to teach the group a sport you are not actually good at.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do a dramatic reaction to an imaginary winning goal.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group give you a complete personality based on your outfit.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Act out how you would handle being completely called out publicly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do your best impression of someone famous with full confidence.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group pick your walk-on song and you must perform your entrance to it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Give a 2-minute TED talk on a topic the group chooses randomly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Demonstrate how you would handle a tough conversation with complete confidence.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Act out your most embarrassing moment in sport or competition.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group pick a ridiculous challenge to complete in 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your best impression of different guy archetypes back to back.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let someone challenge you to a plank contest and see who lasts longer.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do a dramatic reading of any message the group picks from your phone.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Act out how you would behave on the world\'s most awkward first date.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group write your ideal dating app bio and read it out loud.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your best impression of someone much older giving life advice.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Attempt to solve a riddle the group gives you in under 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group vote on your most likely embarrassing habit and confirm if true.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Do your best I am definitely not lost navigation performance.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Act out the most dramatic version of admitting you were completely wrong.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group pick a dramatic movie quote you have to deliver perfectly.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your absolute best I am totally fine performance when you are clearly not.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Demonstrate exactly how you would handle a group roast about yourself.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group rate your confidence across different scenarios 1 to 10.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text: 'Act out meeting your idol and completely losing all composure.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do a dramatic 1-minute inspirational speech about something completely mundane.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group create the most embarrassing possible nickname for you.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Attempt 20 star jumps while maintaining eye contact with someone the whole time.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your best impression of someone confidently giving a nervous speech.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group pick a completely ridiculous challenge and you must accept it.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Tell the room the most embarrassing thing you\'d do for the right person.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your best version of getting hyped up before doing something scary.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Act out how you would handle every possible bad date scenario in 60 seconds.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let someone narrate your life choices for the last year dramatically.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Do your best impression of a motivational speaker giving the absolute worst advice.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Act out the moment you realized you were wrong about something important.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Give a full honest speech about your biggest life lesson so far.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Let the group create the most dramatic sports documentary intro about your life.',
        type: 'dare',
      ),
      GameCardPrompt(
        id: 'gu_d_$i',
        text:
            'Act out your most confident walk into any room and let the group rate it.',
        type: 'dare',
      ),
    ],
  );
}
