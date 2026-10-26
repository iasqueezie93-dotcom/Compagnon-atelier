import 'package:flutter_test/flutter_test.dart';
import 'package:compagnon_atelier/models.dart';

void main() {
  test('parsing OR sans données inventées', () {
    final order=RepairOrder.fromJson({
      'id':123,'number':'OR000123','licensePlate':'AA-123-AA',
      'vehicle':{'brand':'Renault','model':'Clio'},'status':'received'
    },0);
    expect(order.id,'123');
    expect(order.plate,'AA-123-AA');
    expect(order.label,'OR000123');
  });
  test('MO TTC reste une entrée locale', () {
    final entry=ActivityEntry.fromJson({
      'id':'1','label':'Vidange','date':'2026-10-26T09:00:00','amount':64.84,
      'orderId':'123','technician':'A'});
    expect(entry.amount,64.84);
    expect(entry.toJson()['orderId'],'123');
  });
}
