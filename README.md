# 🚀 Powershell-MSPRepository

A community driven repository for useful and unique scripts that we find helpful in our daily work!

## 🔥 What is this?

This is a collaborative space for IT pros and MSP wizards to share PowerShell magic that makes our daily work easier, faster, and more reliable. From automation to reporting, security to system management - if it's a PowerShell script that rocks your world, it belongs here!

## 💻 What's Inside

- **Active Directory Tools** - Make AD management less of a headache
- **System Reporting** - Because data is power 📊
- **Automation Scripts** - Let the robots do the boring stuff
- **Security Tooling** - Keep those systems locked down tight 🔒

## 🛠️ How to Contribute

We're stoked you want to contribute! Here's how to do it right:

### Script Guidelines

1. **Documentation is non-negotiable** 🔍
   - Include proper comment-based help with `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, and `.NOTES`
   - Add your name to the `.NOTES` section so we know who the genius is behind the code

2. **Include Tests** ✅
   - All scripts should have corresponding test files in the `/tests` folder
   - Name test files with the pattern `Original-Script.Tests.ps1`
   - Use Pester for testing whenever possible

3. **Security First** 🛡️
   - **NEVER** include hardcoded credentials
   - **AVOID** requesting passwords in plaintext
   - Use secure methods for credential handling (SecureString, etc.)
   - Include proper error handling for permissions issues

4. **Keep Dependencies Minimal** 🧩
   - Limit external module dependencies when possible
   - If your script requires modules, document them clearly
   - Consider checking for and installing required modules in your script

5. **Clean Code Practices** 🧹
   - Use consistent formatting (4-space indentation preferred)
   - Follow PowerShell best practices for naming (Verb-Noun for functions)
   - Comment your code, especially complex sections
   - Use meaningful variable names (no `$x` or `$temp` without good reason)

### Submission Process

1. Fork this repo
2. Create a feature branch
3. Add your awesome script
4. Add tests in the `/tests` folder
5. Submit a PR with a clear description of what your script does

## 🚫 What Not To Do

- Don't submit scripts without documentation
- Don't include sensitive information (API keys, passwords, private endpoints)
- Don't submit redundant scripts (search first!)
- Don't include excessive external dependencies without justification
- Don't leave debug/testing output in production scripts

## 🌟 Recognition

Contributors get their name in lights! (Well, in the README at least). Regular contributors may be invited to become maintainers.

## 🤝 Code of Conduct

- Be excellent to each other
- Support fellow contributors
- Give constructive feedback
- Remember we were all PowerShell n00bs once

## 📝 License

All scripts are available under the license specified in the LICENSE file. By contributing, you agree to license your code under the same terms.

---

Happy scripting! Remember: with great PowerShell comes great responsibility. 💪

![PowerShell Logo](https://devblogs.microsoft.com/powershell/wp-content/uploads/sites/30/2018/09/Powershell_256.png)

