import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String title;
  final String id;
  final double price;
  final int quantity;
  final String productId;

  CartItem(
      {required this.title,
      required this.id,
      required this.price,
      required this.quantity,
      required this.productId});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).remoteItem(productId);
      },
      child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(
                leading: CircleAvatar(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: FittedBox(
                      child: Text('\$$price'),
                    ),
                  ),
                ),
                title: Text('$title'),
                subtitle: Text('Total: \$${(price * quantity)}'),
                trailing: Text('$quantity x ')),
          )),
    );
  }
}
