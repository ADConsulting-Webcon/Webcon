-- INFO 
-- Replace {User} user login with the COS_BPSID format.

-- Group information

select 
u.COS_BPSID as Login, 
u.COS_DisplayName as Name,
g.COS_DisplayName as GroupName,
iif(g.COS_AccountType = 4, 'AD','BPS') as Type
from [dbo].[CacheOrganizationStructure] u
join [dbo].[CacheOrganizationStructureGroupRelations] gr
on gr.COSGR_UserID = u.COS_ID
join [dbo].[CacheOrganizationStructure] g
on g.COS_ID = gr.COSGR_GroupID
WHERE
u.COS_IsActive = 1 and u.COS_AccountType = 1 and u.COS_BPSID = '{User}'
order by Name

--Global privileges 
SELECT 
 [Name] as [Type of privileges],
iif(SEC_USERGUID='{USER}','User','Group') as [User/Group],
SEC_Username as [Name]
 FROM [dbo].[WFSecurities] 
 JOIN [dbo].[DicSecurityLevels] on SEC_LevelID = [TypeID]
 WHERE SEC_IsPermanent = 1 and  (SEC_USERGUID = '{USER}' or '{USER}' in (select u.COS_BpsID from [dbo].[CacheOrganizationStructure] u join [dbo].[CacheOrganizationStructureGroupRelations] gr on gr.COSGR_UserID = u.COS_ID join [dbo].[CacheOrganizationStructure] g on g.COS_ID = gr.COSGR_GroupID where g.COS_DisplayName = SEC_UserName ))

--Privileges per process

 SELECT 
[Name] as [Type of privileges],
DEF_Name as [Proces],
iif(SEC_USERGUID='{User}','User','Group') as [User/Group],
SEC_Username as [Name]
FROM [dbo].[WFSecurities] 
JOIN [dbo].[DicSecurityLevels] on SEC_LevelID = [TypeID]
JOIN [dbo].WFDefinitions on DEF_ID = SEC_DEFID
WHERE  (SEC_USERGUID = '{User}' or '{User}' in (select u.COS_BpsID from [dbo].[CacheOrganizationStructure] u join [dbo].[CacheOrganizationStructureGroupRelations] gr on gr.COSGR_UserID = u.COS_ID join [dbo].[CacheOrganizationStructure] g on g.COS_ID = gr.COSGR_GroupID where g.COS_DisplayName = SEC_UserName ))
and SEC_DEFID is not null

-- Privileges per Workflow/DocType

SELECT 
[Name] as [Type of privileges],
iif(SEC_USERGUID='{User}','User','Group') as [User/Group],
SEC_Username as [Name],
DEF_Name as Proces,
WF_Name as Workflow,
DTYPE_Name as DocType
FROM [dbo].[WFSecurities] as Sec
JOIN [dbo].[DicSecurityLevels] on SEC_LevelID = [TypeID]
JOIN dbo.DocTypeAssocciations on SEC_ASSID = ASS_ID
JOIN dbo.WorkFlows on WF_ID = ASS_WFID
JOIN dbo.WFDefinitions on WF_WFDEFID = DEF_ID
JOIN dbo.WFDocTypes on DTYPE_ID = ASS_DTYPEID
WHERE  (SEC_USERGUID = '{User}' or '{User}' in (select u.COS_BpsID from [dbo].[CacheOrganizationStructure] u join [dbo].[CacheOrganizationStructureGroupRelations] gr on gr.COSGR_UserID = u.COS_ID join [dbo].[CacheOrganizationStructure] g on g.COS_ID = gr.COSGR_GroupID where g.COS_DisplayName = SEC_UserName ))

-- Privileges per Elements

SELECT 
[Name] as [Type of privileges],
iif(SEC_USERGUID='{User}','User','Group') as [User/Group],
SEC_Username as [Name],
DEF_Name as Proces,
WF_Name as Workflow,
DTYPE_Name as DocType,
WFD_Signature as Signature,
WFD_ID as ID
FROM [dbo].[WFSecurities] as Sec
JOIN [dbo].[DicSecurityLevels] on SEC_LevelID = [TypeID]
JOIN [dbo].[V_WFElements] on SEC_WFDID = WFD_ID
WHERE  (SEC_USERGUID = '{User}' or '{User}' in (select u.COS_BpsID from [dbo].[CacheOrganizationStructure] u join [dbo].[CacheOrganizationStructureGroupRelations] gr on gr.COSGR_UserID = u.COS_ID join [dbo].[CacheOrganizationStructure] g on g.COS_ID = gr.COSGR_GroupID where g.COS_DisplayName = SEC_UserName ))