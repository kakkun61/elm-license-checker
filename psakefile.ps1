Task Setup {
    Exec { npm install }
}

Task Build {
    Exec { npx spago build }
}

Task REPL {
    Exec { npx spago repl }
}

Task Format {
    Exec { Get-ChildItem -Filter '*.hs' -Recurse src | ForEach-Object { npx purty --write $_.FullName } }
}

# call like Invoke-psake -task Release -parameters @{'bump' = 'major'}
Task Release {
    Exec {
        npx spago bump-version --no-dry-run $bump
        npm publish .
        npx pulp publish
    }
}
