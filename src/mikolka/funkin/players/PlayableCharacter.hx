package mikolka.funkin.players;

import mikolka.funkin.Scoring.ScoringRank;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;
import mikolka.funkin.players.PlayerData.PlayerCharSelectData;
import mikolka.funkin.players.PlayerData.PlayerFreeplayDJData;

/**
 * An object used to retrieve data about a playable character (also known as "weeks").
 * Can be scripted to override each function, for custom behavior.
 */
@:nullSafety
class PlayableCharacter
{

  /**
   * Playable character data as parsed from the JSON file.
   */
  public final _data:Null<PlayerData>;

  /**
   * @param id The ID of the JSON file to parse.
   */
  public function new(data:PlayerData)
  {
    _data = data;
  }

  /**
   * Retrieve the readable name of the playable character.
   */
  public function getName():String
  {
    // TODO: Maybe add localization support?
    return _data?.name ?? "Unknown";
  }

  public function getCodename():String
  {
    return _data?.codename ?? "idk";
  }
  

  /**
   * Retrieve the list of stage character IDs associated with this playable character.
   * @return The list of associated character IDs
   */
  public function getOwnedCharacterIds():Array<String>
  {
    return _data?.ownedChars ?? [];
  }

  /**
   * Return `true` if, when this character is selected in Freeplay,
   * songs unassociated with a specific character should appear.
   */
  public function shouldShowUnownedChars():Bool
  {
    return _data?.showUnownedChars ?? false;
  }

  public function shouldShowCharacter(id:String):Bool
  {
    if (getOwnedCharacterIds().contains(id))
    {
      return true;
    }

    if (shouldShowUnownedChars())
    {
      var result = !PlayerRegistry.instance.isCharacterOwned(id);
      return result;
    }

    return false;
  }

  public function getFreeplayStyleID():String
  {
    return _data?.freeplayStyle ?? Constants.DEFAULT_FREEPLAY_STYLE;
  }

  public function getFreeplayDJData():Null<PlayerFreeplayDJData>
  {
    return _data?.freeplayDJ;
  }

  public function getFreeplayDJText(index:Int):String
  {
    // Silly little placeholder
    return _data?.freeplayDJ?.getFreeplayDJText(index) ?? 'GET FREAKY ON A FRIDAY';
  }

  public function getCharSelectData():Null<PlayerCharSelectData>
  {
    return _data?.charSelect;
  }

  /**
   * @param rank Which rank to get info for
   * @return An array of animations. For example, BF Great has two animations, one for BF and one for GF
   */
  public function getResultsAnimationDatas(rank:ScoringRank):Array<PlayerResultsAnimationData>
  {
    if (_data == null || _data.results == null)
    {
      return [];
    }

    switch (rank)
    {
      case PERFECT | PERFECT_GOLD:
        return _data.results.perfect;
      case EXCELLENT:
        return _data.results.excellent;
      case GREAT:
        return _data.results.great;
      case GOOD:
        return _data.results.good;
      case SHIT:
        return _data.results.loss;
    }
  }

  public function getResultsMusicPath(rank:ScoringRank):String
  {
    switch (rank)
    {
      case PERFECT_GOLD:
        return _data?.results?.music?.PERFECT_GOLD ?? "resultsPERFECT";
      case PERFECT:
        return _data?.results?.music?.PERFECT ?? "resultsPERFECT";
      case EXCELLENT:
        return _data?.results?.music?.EXCELLENT ?? "resultsEXCELLENT";
      case GREAT:
        return _data?.results?.music?.GREAT ?? "resultsNORMAL";
      case GOOD:
        return _data?.results?.music?.GOOD ?? "resultsNORMAL";
      case SHIT:
        return _data?.results?.music?.SHIT ?? "resultsSHIT";
      default:
        return _data?.results?.music?.GOOD ?? "resultsNORMAL";
    }
  }

  /**
   * Returns whether this character is unlocked.
   */
  public function isUnlocked():Bool
  {
    return _data?.unlocked ?? true;
  }

  /**
   * Called when the character is destroyed.
   * TODO: Document when this gets called
   */
  public function destroy():Void {}
}
