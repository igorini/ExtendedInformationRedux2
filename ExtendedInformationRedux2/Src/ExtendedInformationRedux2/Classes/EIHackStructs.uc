class EIHackStructs extends Object;

struct HackRewardInfo
{
    var X2HackRewardTemplate RewardTemplate;
    var int RollMod;
    var int Chance;
};

struct EIHackBreakdown
{
    var string RatioLabel;
    var string Ratio;
    var string TechLabel;
    var string TechValue;
    var array<HackRewardInfo> RewardList;
    var array<UISummary_ItemStat> LStats;
    var array<UISummary_ItemStat> RStats;
};