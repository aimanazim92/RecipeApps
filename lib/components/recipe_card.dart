import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../views/recipe_detail_view.dart'; // Import your RecipeDetailScreen

class RecipeCard extends StatelessWidget {
  final String title;
  final int cookTime;
  final String thumbnailUrl;
  final String recipeId;

  RecipeCard({
    required this.title,
    required this.cookTime,
    required this.thumbnailUrl,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailView(recipeId: recipeId,),
          ),
        );
        log("HERE IS RECIPE ID $recipeId" );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0.08 * MediaQuery.of(context).size.width, vertical: 0.02 * MediaQuery.of(context).size.height),
        width: MediaQuery.of(context).size.width,
        height: 0.15 * MediaQuery.of(context).size.height, // Adjust height as needed
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0.0, 10.0),
              blurRadius: 10.0,
              spreadRadius: -6.0,
            ),
          ],
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35),
              BlendMode.multiply,
            ),
            image: NetworkImage(thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.02 * MediaQuery.of(context).size.width),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 0.04 * MediaQuery.of(context).size.width, color: Colors.white), // Adjust font size
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(0.01 * MediaQuery.of(context).size.width),
                    margin: EdgeInsets.all(0.02 * MediaQuery.of(context).size.width),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.yellow,
                          size: 0.03 * MediaQuery.of(context).size.width, // Adjust icon size
                        ),
                        SizedBox(width: 0.015 * MediaQuery.of(context).size.width),
                        Text(
                          '$cookTime min ',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
