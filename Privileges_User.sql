---- User in group --------
SELECT 
	u.COS_BpsID, 
	u.COS_DisplayName, 
	gr.COSGR_TSInsert AS TSInsert 
FROM [dbo].[CacheOrganizationStructure] u 
JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr ON gr.COSGR_UserID = u.COS_ID 
JOIN [dbo].[CacheOrganizationStructure] g ON g.COS_ID = gr.COSGR_GroupID 
WHERE g.COS_BPSID = '{GroupBPSID}'
---- Global privileges --------
SELECT 
	[Name] AS [Type of privileges]
FROM [dbo].[WFSecurities] 
JOIN [dbo].[DicSecurityLevels] ON SEC_LevelID = [TypeID] 
WHERE SEC_IsPermanent = 1 
	AND (SEC_USERGUID = '{GroupBPSID}') 
UNION ALL 
SELECT 
	'SysAdmin' as [Type of privileges]
FROM [dbo].[WFConfigurationSecurities] 
WHERE [CSC_IsGlobal] = 1 
	and CSC_LevelID = 1 
	and (CSC_USERGUID = '{GroupBPSID}')
------ Application privileges --------
SELECT 
	CASE CSC_LevelID
		WHEN 1 THEN 'Admin'
		WHEN 2 THEN 'Portal designer'
		WHEN 3 THEN 'Metadata access'
		WHEN 4 THEN 'Access to Application'
		ELSE 'Unknown'
	END AS  [Type of privileges], 
	APP_Name AS [Application] 
FROM dbo.WFConfigurationSecurities 
JOIN dbo.WFApplications ON CSC_APPID = APP_ID 
WHERE (CSC_USERGUID = '{GroupBPSID}')
-------- Privileges per process --------
SELECT 
	[Name] AS [Type of privileges], 
	DEF_Name AS [Proces]
FROM [dbo].[WFSecurities] 
JOIN [dbo].[DicSecurityLevels] ON SEC_LevelID = [TypeID] 
JOIN [dbo].[WFDefinitions] ON DEF_ID = SEC_DEFID 
WHERE (SEC_USERGUID = '{GroupBPSID}') AND SEC_DEFID IS NOT NULL
------- Privileges per Workflow/DocType --------
SELECT 
	[Name] AS [Type of privileges], 
	DEF_Name AS Proces, 
	WF_Name AS Workflow, 
	DTYPE_Name AS DocType 
FROM [dbo].[WFSecurities] AS Sec 
JOIN [dbo].[DicSecurityLevels] ON SEC_LevelID = [TypeID] 
JOIN dbo.DocTypeAssocciations ON SEC_ASSID = ASS_ID 
JOIN dbo.WorkFlows ON WF_ID = ASS_WFID 
JOIN dbo.WFDefinitions ON WF_WFDEFID = DEF_ID 
JOIN dbo.WFDocTypes ON DTYPE_ID = ASS_DTYPEID 
WHERE (SEC_USERGUID = '{GroupBPSID}')
------- Privileges per Elements --------
SELECT 
	[Name] AS [Type of privileges], 
	DEF_Name AS Proces, 
	WF_Name AS Workflow, 
	DTYPE_Name AS DocType, 
	WFD_Signature AS Signature, 
	WFD_ID AS ID 
FROM [dbo].[WFSecurities] AS Sec 
JOIN [dbo].[DicSecurityLevels] ON SEC_LevelID = [TypeID] 
JOIN [dbo].[V_WFElements] ON SEC_WFDID = WFD_ID 
WHERE (SEC_USERGUID = '{GroupBPSID}')
------- Group use in Action --------
SELECT 
	'UseInAction' as Type, 
	INact.ACT_ID AS ACT_ID, 
	EnglishName as ActionType, 
	INact.ACT_Name as ActionName, 
	def.DEF_Name AS Process, 
	app.APP_Name AS Application
FROM WFBusinessRuleDefinitions BRD_INAction 
JOIN WFActionBusinessRules a ON a.ABR_BRDID = BRD_INAction.BRD_ID 
LEFT JOIN WFActions INact ON INact.ACT_ID = a.ABR_ACTID 
LEFT JOIN WFDefinitions def ON def.DEF_ID = BRD_INAction.BRD_DEFID 
LEFT JOIN WFApplications app ON app.APP_ID = def.DEF_APPID 
LEFT JOiN DicActionKinds on INact.ACT_ActionKindID = TypeID 
WHERE 
	INact.ACT_ID is not null 
	and BRD_INAction.BRD_ID in (SELECT * FROM dbo.ADC_GetGroupBusinessRules('{GroupBPSID}')) 
UNION ALL 
SELECT 
	'UseInAction' as Type, 
	INact.ACT_ID AS ACT_ID, 
	EnglishName as ActionType, 
	INact.ACT_Name as ActionName, 
	def.DEF_Name AS Process, 
	app.APP_Name AS Application
FROM WFActions INact 
LEFT JOIN Automations autm ON autm.AUTM_ID = INact.ACT_AUTMID 
LEFT JOIN WFDefinitions def ON def.DEF_ID = autm.AUTM_DEFID 
LEFT JOIN WFApplications app ON app.APP_ID = def.DEF_APPID 
LEFT JOiN DicActionKinds on INact.ACT_ActionKindID = TypeID 
WHERE 
	INact.ACT_Configuration like '%{GroupBPSID}%' 
UNION ALL 
SELECT 
	'UseInActivationAction' as Type, 
	ActivationBRD.ACT_ID AS ACT_ID, 
	EnglishName as ActionType, 
	ActivationBRD.ACT_Name as ActionName, 
	def.DEF_Name AS Process, 
	app.APP_Name AS Application
FROM WFBusinessRuleDefinitions BRD_ActivationAction 
LEFT JOIN WFActions ActivationBRD on ActivationBRD.ACT_ActivationBRDID = BRD_ActivationAction.BRD_ID 
LEFT JOIN WFDefinitions def ON def.DEF_ID = BRD_ActivationAction.BRD_DEFID 
LEFT JOIN WFApplications app ON app.APP_ID = def.DEF_APPID 
LEFT JOIN DicActionKinds on ActivationBRD.ACT_ActionKindID = TypeID 
WHERE 
	ActivationBRD.ACT_ID is not null 
	and BRD_ActivationAction.BRD_ID in (SELECT * FROM dbo.ADC_GetGroupBusinessRules('{GroupBPSID}'))
----------- Group use in Field --------
SELECT 
	WFCON_ID as FieldID, 
	WFCON_Prompt as FieldPrompt, 
	iif([WFCON_IsVisibleSqlBRDID] = BRD_Field.BRD_ID,1,0) as FieldVisible,
	iif([WFCON_EditModeSqlBRDID] = BRD_Field.BRD_ID,1,0) as FieldEditMode,
	iif([WFCON_IsRequiredSqlBRDID] = BRD_Field.BRD_ID,1,0) as FieldRequired,
	iif([WFCON_DefaultBRDID] = BRD_Field.BRD_ID,1,0) as FieldDefaultValue,
	def.DEF_Name AS Process, 
	app.APP_Name AS Application 
FROM WFBusinessRuleDefinitions BRD_Field 
JOIN [WFConfigurations] ON [WFCON_IsVisibleSqlBRDID] = BRD_Field.BRD_ID 
	or [WFCON_EditModeSqlBRDID] = BRD_Field.BRD_ID 
	or [WFCON_IsRequiredSqlBRDID] = BRD_Field.BRD_ID 
	or [WFCON_DefaultBRDID] = BRD_Field.BRD_ID 
LEFT JOIN WFDefinitions def ON def.DEF_ID = BRD_Field.BRD_DEFID 
LEFT JOIN WFApplications app ON app.APP_ID = def.DEF_APPID 
WHERE BRD_Field.BRD_ID in (SELECT * FROM [dbo].[ADC_GetGroupBusinessRules] ('{GroupBPSID}'))
-------- Group use in Path --------
SELECT 
DEF_Name as Process,
APP_Name as Application,
WF_Name as Workflows,
STP_Name as Step, 
PATH_Name as PathName,
PATH_ID
FROM WFAvaiblePaths 
JOIN WFSteps on PATH_STPID = STP_ID
JOIN WorkFlows on STP_WFID = WF_ID 
JOIN WFDefinitions on WF_WFDEFID = DEF_ID
LEFT JOIN WFApplications app ON APP_ID = DEF_APPID
where PATH_AssignmentsBRDID in (SELECT * FROM [dbo].[ADC_GetGroupBusinessRules] ('{GroupBPSID}')) 
	or PATH_AssignmentsDWBRDID in (SELECT * FROM [dbo].[ADC_GetGroupBusinessRules] ('{GroupBPSID}'))
