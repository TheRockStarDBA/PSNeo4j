﻿function Add-Neo4jConstraint {
    [cmdletbinding(DefaultParameterSetName = 'Node')]
    param(
        [parameter(ParameterSetName = 'Node')]
        [string]$Label, # Injection alert
        [parameter(ParameterSetName = 'Relationship')]
        [string]$Relationship, # Injection alert
        [string[]]$Property, # Injection alert
        
        [parameter(ParameterSetName = 'Node')]
        [switch]$Unique,
        [parameter(ParameterSetName = 'Node')]
        [switch]$Exists,

        [switch]$Raw,
        [switch]$ExpandResults,
        [switch]$ExpandRow,
        [validateset('id', 'type', 'deleted')]
        [string]$MetaProperties,
        [string]$MergePrefix = 'Neo4j',

        [string]$BaseUri = $PSNeo4jConfig.BaseUri,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential =  $PSNeo4jConfig.Credential  
    )
    $Query = [System.Collections.ArrayList]@()
    if($PSCmdlet.ParameterSetName -eq 'Node') {
        write-verbose 'NODE'
        if($Unique) {
            Foreach($Prop in $Property) {
                write-verbose $prop
                [void]$Query.add("CREATE CONSTRAINT ON (l:$Label) ASSERT l.$Prop IS UNIQUE")
            }            
        }
        If($Exists) {
            Foreach($Prop in $Property) {
                # Requires enterprise. Interesting
                write-verbose $prop
                [void]$Query.add("CREATE CONSTRAINT ON (l:$Label) ASSERT exists(l.$Prop)")
            }
        }
    }
    if($PSCmdlet.ParameterSetName -eq 'Relationship') {
        write-verboe 'relationship'
        Foreach($Prop in $Property) {
            # Requires enterprise. Interesting
            [void]$Query.add("CREATE CONSTRAINT ON ()-[l:$Relationship]-() ASSERT exists(l.$Prop)")
        }
    }
    # TOOO: http://neo4j.com/docs/developer-manual/current/cypher/schema/constraints/#constraints-drop-a-node-key

    Write-Verbose "Query: [$Query]"
    $Params = . Get-ParameterValues -Properties Raw, ExpandResults, ExpandRow, MetaProperties, MergePrefix
    Invoke-Neo4jQuery @Params -Query $Query
}