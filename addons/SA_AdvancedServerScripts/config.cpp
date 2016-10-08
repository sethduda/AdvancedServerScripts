class CfgPatches
{
	class SA_AdvancedServerScripts
	{
		units[] = {"SA_AdvancedServerScripts"};
		requiredVersion = 1.0;
		requiredAddons[] = {"A3_Modules_F"};
	};
};

class CfgFunctions 
{
	class SA
	{
		class AdvancedServerScripts
		{
			file = "\SA_AdvancedServerScripts\functions";
			class advancedServerScriptsInit{postInit=1};
		};
	};
};