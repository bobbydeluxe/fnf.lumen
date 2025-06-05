/* Pico's Results Screen Recolor Script
 * This script modifies the background and rank text of Pico's results screen as he has a blue freeplay card as opposed to BF's yellow one.
 * place this file in `mods/<mod_name>/scripts/registry/results/picoCard.hx`
 * [or `[playerCodename]Card.hx` for any character specific recolor or `main.hx` for a general recolor]
 */

 import flixel.util.FlxGradient;

 var bgBlue:FlxSprite;
 var bgBlueFL:FlxSprite;
 var rankName:String;
 
 function onLoad(name, obj)
 {
     if (name == "bgSprite") {
         bgBlue = obj;
         bgBlue.pixels = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xff7488fd, 0xff5c74fe], 90).pixels;
     }
     if (name == "bgSpriteFlash") {
         bgBlueFL = obj;
         bgBlueFL.pixels = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xffa6b4ff, 0xffbeccff], 90).pixels;
     }
     if (name == "playerRank") {
         var rank = obj;
         rankName = Std.string(rank).toLowerCase();
         trace("Rank is: " + rankName);
     }
     if (name == "rankTextBack") {
         var rankTextBack = obj;
         var rankNameFinal = switch (rankName.toLowerCase()) {
             case "shit": "loss";
             case "perfect_gold": "perfect";
             default: rankName.toUpperCase();
         }
 
         if (rankName != null) {
             var newPath = "resultScreen/rankText/white/rankScroll" + rankNameFinal;
             rankTextBack.loadGraphic(Paths.image(newPath));
             rankTextBack.color = 0xFF85A3FF;
         }
     }
 }