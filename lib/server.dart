import 'package:mongo_dart/mongo_dart.dart';
import 'package:sevr/sevr.dart';

void start() async {
  const username = 'saksham';
  const password = 'saksham';
  const database = 'apptest';

  // Connect to the server
  const url =
      'mongodb+srv://${username}:${password}@cluster0.ayj3r.mongodb.net/${database}?retryWriteCONNECTs=true&w=majority';

  final db = await Db.create('${url}');
  await db.open();

  // Connection successful
  print('Connection successful');

  // Port
  const port = 3000;

  // Initialise server
  final serv = Sevr();

  // Connect to individual collections
  final prof = db.collection('prof');
  final Aprof = db.collection('Aprof');
  final phd = db.collection('phd');
  final resources = db.collection('resources');
  final users = db.collection('users');

  // Server listens to https requests on "${port}" port
  serv.listen(port, callback: () {
    print('Listening on port: ${port}');
  });

  // GET Requests

  //LOGIN
  // ------------------------
  // request parameters:
  // ?username=[input_username]
  //
  // response parameters:
  // .json(
  // {'user_exists': 'Yes/No', 'verified': 'Yes/No'}
  // )

  serv.get('/login', [
    (ServRequest req, ServResponse res) async {
      var user = await users.findOne(where.eq('userId', req.body['username']));
      if (user != null) {
        if (user['password'] == req.body['password']) {
          return res
              .status(200)
              .json({'user_exists': 'Yes', 'verified': 'Yes'});
        } else {
          return res.status(200).json({'user_exists': 'Yes', 'verified': 'No'});
        }
      } else {
        return res.status(200).json({'user_exists': 'No', 'verified': 'No'});
      }
    }
  ]);
  // ------------------------

  //SHOW INDIVIDUAL PAGE
  serv.get('/individualPage/:type', [
    //NEEDS WORK
    (ServRequest req, ServResponse res) async {
      print('Insearch');
      if (req.params['type'] == 'prof') {
        var user = await prof.findOne(where.eq('name', req.body['name']));
        if (user != null) {
          return res.status(200).json({'userdata': user, 'found': 'true'});
        } else {
          return res.status(200).json({'found': 'false'});
        }
      } else if (req.params['type'] == 'Aprof') {
        var user = await Aprof.findOne(where.eq('name', req.body['name']));
        if (user != null) {
          return res.status(200).json({'userdata': user});
        } else {
          return res.status(200).json({'found': 'false'});
        }
      } else if (req.params['type'] == 'phd') {
        var user = await phd.findOne(where.eq('name', req.body['name']));
        if (user != null) {
          return res.status(200).json({'userdata': user});
        } else {
          return res.status(200).json({'found': 'false'});
        }
      } else if (req.params['type'] == 'resources') {
        var user = await resources.findOne(where.eq('name', req.body['name']));
        if (user != null) {
          return res.status(200).json({'userdata': user});
        } else {
          return res.status(200).json({'found': 'false'});
        }
      } else {
        return res.status(200).json({'status': 'notFound'});
      }
    }
  ]);

  //SHOW DEPARTMENT PAGE
  // -----------------------
  // Request params: ?dept:[input_dept]
  // Response:
  // .json(
  //   {
  //    'profList': profList,
  //    'AprofList': AprofList,
  //    'phdList': phdList,
  //    'resourcesList': resourcesList
  //   }
  // )

  serv.get('/department', [
    (ServRequest req, ServResponse res) async {
      var profList = prof.find(where.eq('dept', req.body['dept'])).toList();
      var AprofList = Aprof.find(where.eq('dept', req.body['dept'])).toList();
      var phdList = phd.find(where.eq('dept', req.body['dept'])).toList();
      var resourcesList =
          resources.find(where.eq('dept', req.body['dept'])).toList();
      return res.status(200).json({
        'profList': profList,
        'AprofList': AprofList,
        'phdList': phdList,
        'resourcesList': resourcesList
      });
    }
  ]);
  // ---------------------

  //SHOW PROF/APROF/PHD/RESOURCES PAGE
  serv.get('/listPage/:type', [
    (ServRequest req, ServResponse res) async {
      if (req.params['type'] == 'prof') {
        var list = prof.find().toList();
        return res.status(200).json({'list': list});
      } else if (req.params['type'] == 'Aprof') {
        var list = Aprof.find().toList();
        return res.status(200).json({'list': list});
      } else if (req.params['type'] == 'phd') {
        var list = phd.find().toList();
        return res.status(200).json({'list': list});
      } else if (req.params['type'] == 'resources') {
        var list = resources.find().toList();
        return res.status(200).json({'list': list});
      }
    }
  ]);

  //USER LIST
  serv.get('/user', [
    (ServRequest req, ServResponse res) async {
      var userList = users.find().toList();
      return res.status(200).json({'userList': userList});
    }
  ]);

  // POST Requests

  //REGISTER
  serv.post('/register/:type', [
    (ServRequest req, ServResponse res) async {
      if (req.params['type'] != 'resources') {
        await users.insert(
            {'userId': req.body['login'], 'password': req.body['password']});
        print('inserted');
      }
      print(req.params['type']);
      if (req.params['type'] == 'prof') {
        await prof.insert({
          'userId': req.body['login'],
          //  'password': req.body['password'],
          'name': req.body['name'],
          'dept': req.body['dept'],
          'education': req.body['education'],
          'DoJ': req.body['date'],
          'additional': req.body['additional']
        });
        print('prof inserted');
      } else if (req.params['type'] == 'Aprof') {
        await Aprof.insert({
          'userId': req.body['login'],
          //'password': req.body['password'],
          'name': req.body['name'],
          'dept': req.body['dept'],
          'education': req.body['education'],
          'DoJ': req.body['date'],
          'additional': req.body['additional']
        });
      } else if (req.params['type'] == 'phd') {
        await phd.insert({
          'userId': req.body['login'],
          // 'password': req.body['password'],
          'name': req.body['name'],
          'dept': req.body['dept'],
          'education': req.body['education'],
          'DoJ': req.body['date'],
          'thesis': req.body['thesis']
        });
      } else if (req.params['type'] == 'resources') {
        await resources.insert({
          'type': req.body['name'],
          'dept': req.body['dept'],
          'capacity': req.body['education'],
          'LabAsst': req.body['date'],
        });
      }
      return res.status(200).json({'inserted': 'Ok'});
    }
  ]);

  //UPDATE
  serv.post('/editProfile/:type', [
    (ServRequest req, ServResponse res) async {
      if (req.params['type'] == 'prof') {
        await prof.update(
            await where.eq('name', req.body['name']), req.body['newData']);
        return res.status(200).json({'updated': 'true'});
      } else if (req.params['type'] == 'Aprof') {
        await Aprof.update(
            await where.eq('name', req.body['name']), req.body['newData']);
        return res.status(200).json({'updated': 'true'});
      } else if (req.params['type'] == 'phd') {
        await phd.update(
            await where.eq('name', req.body['name']), req.body['newData']);
        return res.status(200).json({'updated': 'true'});
      } else if (req.params['type'] == 'resources') {
        await resources.update(
            await where.eq('name', req.body['name']), req.body['newData']);
        return res.status(200).json({'updated': 'true'});
      }
    }
  ]);
}
