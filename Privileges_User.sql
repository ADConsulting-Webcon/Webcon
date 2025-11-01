-- INFO 
-- Replace {User} user login with the COS_BPSID format.

---------------------------------------------------
-- Group information
---------------------------------------------------
SELECT 
    u.COS_BPSID       AS Login, 
    u.COS_DisplayName AS Name,
    g.COS_DisplayName AS GroupName,
    gr.COSGR_TSInsert AS TSInsert,
    IIF(g.COS_AccountType = 4, 'AD', 'BPS') AS Type
FROM [dbo].[CacheOrganizationStructure] u
JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr
    ON gr.COSGR_UserID = u.COS_ID
JOIN [dbo].[CacheOrganizationStructure] g
    ON g.COS_ID = gr.COSGR_GroupID
WHERE u.COS_IsActive = 1
  AND u.COS_AccountType = 1
  AND u.COS_BPSID = '{User}'
ORDER BY Name;

---------------------------------------------------
-- Global privileges 
---------------------------------------------------
SELECT 
    [Name] AS [Type of privileges],
    IIF(SEC_USERGUID = '{USER}', 'User', 'Group') AS [User/Group],
    SEC_Username AS [Name]
FROM [dbo].[WFSecurities] 
JOIN [dbo].[DicSecurityLevels] 
    ON SEC_LevelID = [TypeID]
WHERE SEC_IsPermanent = 1
  AND (
        SEC_USERGUID = '{USER}' 
        OR '{USER}' IN (
            SELECT u.COS_BpsID
            FROM [dbo].[CacheOrganizationStructure] u
            JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr
                ON gr.COSGR_UserID = u.COS_ID
            JOIN [dbo].[CacheOrganizationStructure] g
                ON g.COS_ID = gr.COSGR_GroupID
            WHERE g.COS_BPSID = SEC_USERGUID
        )
      )
UNION ALL
SELECT 
'SysAdmin' as [Type of privileges],
IIF(CSC_USERGUID = '{USER}', 'User', 'Group') AS [User/Group],
CSC_UserName as [Name]
FROM [dbo].[WFConfigurationSecurities] 
WHERE [CSC_IsGlobal] = 1 and CSC_LevelID = 1 and 
(
    CSC_USERGUID = '{USER}'
     OR '{USER}' IN (
            SELECT u.COS_BpsID
            FROM [dbo].[CacheOrganizationStructure] u
            JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr
                ON gr.COSGR_UserID = u.COS_ID
            JOIN [dbo].[CacheOrganizationStructure] g
                ON g.COS_ID = gr.COSGR_GroupID
            WHERE g.COS_BPSID= CSC_USERGUID
        )
)

---------------------------------------------------
-- Privileges per process
---------------------------------------------------
SELECT 
    [Name] AS [Type of privileges],
    DEF_Name AS [Proces],
    IIF(SEC_USERGUID = '{User}', 'User', 'Group') AS [User/Group],
    SEC_Username AS [Name]
FROM [dbo].[WFSecurities] 
JOIN [dbo].[DicSecurityLevels] 
    ON SEC_LevelID = [TypeID]
JOIN [dbo].[WFDefinitions] 
    ON DEF_ID = SEC_DEFID
WHERE (
        SEC_USERGUID = '{User}' 
        OR '{User}' IN (
            SELECT u.COS_BpsID
            FROM [dbo].[CacheOrganizationStructure] u
            JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr
                ON gr.COSGR_UserID = u.COS_ID
            JOIN [dbo].[CacheOrganizationStructure] g
                ON g.COS_ID = gr.COSGR_GroupID
            WHERE g.COS_BPSID = SEC_USERGUID
        )
      )
  AND SEC_DEFID IS NOT NULL;

---------------------------------------------------
-- Privileges per Workflow/DocType
---------------------------------------------------
SELECT 
    [Name] AS [Type of privileges],
    IIF(SEC_USERGUID = '{User}', 'User', 'Group') AS [User/Group],
    SEC_Username AS [Name],
    DEF_Name AS Proces,
    WF_Name AS Workflow,
    DTYPE_Name AS DocType
FROM [dbo].[WFSecurities] AS Sec
JOIN [dbo].[DicSecurityLevels] 
    ON SEC_LevelID = [TypeID]
JOIN dbo.DocTypeAssocciations 
    ON SEC_ASSID = ASS_ID
JOIN dbo.WorkFlows 
    ON WF_ID = ASS_WFID
JOIN dbo.WFDefinitions 
    ON WF_WFDEFID = DEF_ID
JOIN dbo.WFDocTypes 
    ON DTYPE_ID = ASS_DTYPEID
WHERE (
        SEC_USERGUID = '{User}' 
        OR '{User}' IN (
            SELECT u.COS_BpsID
            FROM [dbo].[CacheOrganizationStructure] u
            JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr
                ON gr.COSGR_UserID = u.COS_ID
            JOIN [dbo].[CacheOrganizationStructure] g
                ON g.COS_ID = gr.COSGR_GroupID
            WHERE g.COS_BPSID = SEC_USERGUID
        )
      );

---------------------------------------------------
-- Privileges per Elements
---------------------------------------------------
SELECT 
    [Name] AS [Type of privileges],
    IIF(SEC_USERGUID = '{User}', 'User', 'Group') AS [User/Group],
    SEC_Username AS [Name],
    DEF_Name AS Proces,
    WF_Name AS Workflow,
    DTYPE_Name AS DocType,
    WFD_Signature AS Signature,
    WFD_ID AS ID
FROM [dbo].[WFSecurities] AS Sec
JOIN [dbo].[DicSecurityLevels] 
    ON SEC_LevelID = [TypeID]
JOIN [dbo].[V_WFElements] 
    ON SEC_WFDID = WFD_ID
WHERE (
        SEC_USERGUID = '{User}' 
        OR '{User}' IN (
            SELECT u.COS_BpsID
            FROM [dbo].[CacheOrganizationStructure] u
            JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr
                ON gr.COSGR_UserID = u.COS_ID
            JOIN [dbo].[CacheOrganizationStructure] g
                ON g.COS_ID = gr.COSGR_GroupID
            WHERE g.COS_BPSID = SEC_USERGUID
        )
      );

---------------------------------------------------
-- User in Group 
---------------------------------------------------
          SELECT u.COS_BpsID
            FROM [dbo].[CacheOrganizationStructure] u
            JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr
                ON gr.COSGR_UserID = u.COS_ID
            JOIN [dbo].[CacheOrganizationStructure] g
                ON g.COS_ID = gr.COSGR_GroupID
            WHERE g.COS_BPSID = {COS_BPSID_Group}

          SELECT u.COS_BpsID
            FROM [dbo].[CacheOrganizationStructure] u
            JOIN [dbo].[CacheOrganizationStructureGroupRelations] gr
                ON gr.COSGR_UserID = u.COS_ID
            JOIN [dbo].[CacheOrganizationStructure] g
                ON g.COS_ID = gr.COSGR_GroupID
            WHERE g.COS_DisplayName = {COS_DisplayName_Group}
