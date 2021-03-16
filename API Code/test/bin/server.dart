import 'package:mongo_dart/mongo_dart.dart';
import 'package:sevr/sevr.dart';

Future<void> start() async {
  final db = await Db.create(
      'mongodb+srv://saksham:saksham@cluster0.ayj3r.mongodb.net/apptest?retryWrites=true&w=majority');
  await db.open();

  const port = 3000;
  final serv = Sevr();

  final prof = db.collection('prof');
  final Aprof = db.collection('Aprof');
  final phd = db.collection('phd');
  final resources = db.collection('resources');
  final users = db.collection('users');

  serv.listen(port, callback: () {
    print('listening of $port');
  });

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
          'id': req.body['id'],
          'type': req.body['type'],
          'dept': req.body['dept'],
          'capacity': req.body['capacity'],
          'LabAsst': req.body['LabAsst'],
        });
      }
      return res.status(200).json({'inserted': 'Ok'});
    }
  ]);
  print(await users.findOne(where.eq('userName', 'Prasad')));
  //LOGIN
  serv.get('/login', [
    (ServRequest req, ServResponse res) async {
      print('InLogin');
      var user = await users.findOne(where.eq('userId', req.query['login']));
      if (user != null) {
        if (user['password'] == req.query['password']) {
          return res.status(200).json({'verified': 'Yes'});
        }
      } else {
        return res.status(200).json({'verified': 'No'});
      }
    }
  ]);

  //SHOW INDIVIDUAL PAGE
  // DONE

  serv.get('/individualPage/:type', [
    (ServRequest req, ServResponse res) async {
      print('Insearch');
      if (req.params['type'] == 'prof') {
        var user = await prof.findOne(where.eq('name', req.query['name']));
        if (user != null) {
          return res.status(200).json({'userdata': user, 'found': 'true'});
        } else {
          return res.status(200).json({'found': 'false'});
        }
      } else if (req.params['type'] == 'Aprof') {
        var user = await Aprof.findOne(where.eq('name', req.query['name']));
        if (user != null) {
          return res.status(200).json({'userdata': user});
        } else {
          return res.status(200).json({'found': 'false'});
        }
      } else if (req.params['type'] == 'phd') {
        var user = await phd.findOne(where.eq('name', req.query['name']));
        if (user != null) {
          return res.status(200).json({'userdata': user});
        } else {
          return res.status(200).json({'found': 'false'});
        }
      } else if (req.params['type'] == 'resources') {
        var user = await resources.findOne(where.eq('id', req.query['id']));
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
  serv.get('/department', [
    (ServRequest req, ServResponse res) async {
      var profList =
          await prof.find(where.eq('dept', req.query['dept'])).toList();
      var AprofList =
          await Aprof.find(where.eq('dept', req.query['dept'])).toList();
      var phdList =
          await phd.find(where.eq('dept', req.query['dept'])).toList();
      var resourcesList =
          await resources.find(where.eq('dept', req.query['dept'])).toList();

      return res.status(200).json({
        'profList': profList,
        'AprofList': AprofList,
        'phdList': phdList,
        'resourcesList': resourcesList
      });
    }
  ]);

  //SHOW PROF/APROF/PHD/RESOURCES PAGE
  serv.get('/listPage/:type', [
    (ServRequest req, ServResponse res) async {
      if (req.params['type'] == 'prof') {
        var list = await prof.find().toList();
        return res.status(200).json({'list': list});
      } else if (req.params['type'] == 'Aprof') {
        final list = await Aprof.find().toList();
        return res.status(200).json({'list': list});
      } else if (req.params['type'] == 'phd') {
        var list = await phd.find().toList();
        return res.status(200).json({'list': list});
      } else if (req.params['type'] == 'resources') {
        var list = await resources.find().toList();
        return res.status(200).json({'list': list});
      }
    }
  ]);
  //USER LIST
  serv.get('/user', [
    (ServRequest req, ServResponse res) async {
      var userList = await users.find().toList();
      return res.status(200).json({'userList': userList});
    }
  ]);
//UPDATE
  serv.post('/editProfile/:type', [
    (ServRequest req, ServResponse res) async {
      if (req.params['type'] == 'prof') {
        await prof.update(
            where.eq('name', req.body['name']), req.body['newData']);
        return res.status(200).json({'updated': 'true'});
      } else if (req.params['type'] == 'Aprof') {
        await Aprof.update(
            where.eq('name', req.body['name']), req.body['newData']);
        return res.status(200).json({'updated': 'true'});
      } else if (req.params['type'] == 'phd') {
        await phd.update(
            where.eq('name', req.body['name']), req.body['newData']);
        return res.status(200).json({'updated': 'true'});
      } else if (req.params['type'] == 'resources') {
        await resources.update(
            where.eq('name', req.body['name']), req.body['newData']);
        return res.status(200).json({'updated': 'true'});
      }
    }
  ]);
}
