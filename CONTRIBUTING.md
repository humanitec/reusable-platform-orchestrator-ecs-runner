# Contributing to ECS Runner Module

Thank you for your interest in contributing to the ECS Runner module! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow. Please be respectful and professional in all interactions.

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. Check if the issue already exists in the GitHub Issues
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Terraform version and provider versions
   - Relevant configuration snippets

### Submitting Changes

1. **Fork the repository** and create a new branch for your changes
2. **Make your changes** following the guidelines below
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description of your changes

## Development Guidelines

### Terraform Code Standards

- Follow [Terraform style conventions](https://www.terraform.io/docs/language/syntax/style.html)
- Use `terraform fmt` to format your code
- Run `terraform validate` to check syntax
- Use meaningful variable and resource names
- Add comments for complex logic

### Variable Naming

- Use snake_case for variable names
- Prefix boolean variables with `enable_` or `is_`
- Use descriptive names that indicate purpose
- Document all variables with clear descriptions

Example:
```hcl
variable "enable_s3_encryption" {
  description = "Enable encryption for S3 bucket using AWS managed keys (SSE-S3)"
  type        = bool
  default     = true
}
```

### Resource Naming

- Use consistent naming patterns
- Include the runner ID in resource names
- Use random suffixes to avoid naming conflicts
- Tag all resources appropriately

### IAM Security

When adding or modifying IAM policies:
- Follow the principle of least privilege
- Use resource-level permissions when possible
- Add conditions to restrict access
- Document why each permission is needed

### Documentation

- Update README.md for user-facing changes
- Update SECURITY.md for security-related changes
- Update ARCHITECTURE.md for architectural changes
- Add examples for new features
- Update variable tables in README.md

### Testing

#### Required Tests

Before submitting a PR, ensure:

1. **Terraform Validation**
   ```bash
   terraform init
   terraform validate
   ```

2. **Terraform Format**
   ```bash
   terraform fmt -check -recursive
   ```

3. **Terraform Test** (if applicable)
   ```bash
   terraform test
   ```

4. **Example Validation**
   ```bash
   cd examples/basic
   terraform init
   terraform validate
   
   cd ../complete-production
   terraform init
   terraform validate
   ```

#### Testing Changes

For significant changes:
- Test in a real AWS environment if possible
- Verify in both new and existing cluster scenarios
- Test with and without optional features
- Verify outputs are correct
- Check CloudWatch logs are generated
- Verify S3 bucket is created correctly

### Commit Messages

Use clear, descriptive commit messages:

```
Add KMS encryption support for S3 bucket

- Add kms_key_arn variable
- Configure S3 bucket server-side encryption
- Update documentation
- Add example configuration
```

Format:
- First line: Brief summary (50 chars or less)
- Blank line
- Detailed description with bullet points
- Reference issue numbers if applicable

### Pull Request Process

1. **Create a descriptive PR title**
   - Bad: "Update main.tf"
   - Good: "Add CloudWatch log encryption with KMS"

2. **Provide a detailed description**
   - What changes were made
   - Why they were needed
   - How to test the changes
   - Any breaking changes

3. **Link related issues**
   - Use "Fixes #123" or "Closes #123"

4. **Respond to feedback**
   - Be open to suggestions
   - Make requested changes promptly
   - Ask questions if unclear

5. **Keep PRs focused**
   - One feature/fix per PR
   - Split large changes into smaller PRs

## Security Considerations

### Security Vulnerabilities

If you discover a security vulnerability:
- **DO NOT** open a public issue
- Contact the maintainers privately
- Provide detailed information about the vulnerability
- Allow time for a fix before public disclosure

### Security Best Practices

When contributing:
- Never commit secrets or credentials
- Use secure defaults
- Enable encryption by default
- Follow AWS security best practices
- Add appropriate IAM conditions

## Adding New Features

When proposing new features:

1. **Open an issue first** to discuss the feature
2. **Get feedback** from maintainers
3. **Consider backward compatibility**
4. **Add comprehensive tests**
5. **Update all relevant documentation**
6. **Provide examples** of how to use the feature

### Feature Checklist

- [ ] Issue created and discussed
- [ ] Code implemented
- [ ] Tests added
- [ ] Documentation updated
- [ ] Examples added (if applicable)
- [ ] Backward compatible (or migration path provided)
- [ ] Security considerations addressed
- [ ] Performance impact considered

## Documentation Guidelines

### README.md

- Keep it concise but comprehensive
- Update usage examples
- Update variable and output tables
- Add troubleshooting tips if relevant

### Code Comments

- Comment complex logic
- Explain "why" not just "what"
- Keep comments up to date
- Use TODO comments sparingly

### Examples

When adding examples:
- Include a README.md
- Provide terraform.tfvars.example
- Document prerequisites
- Explain what the example demonstrates
- Include cost estimates if significant

## Release Process

Maintainers follow semantic versioning:
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

## Getting Help

If you need help:
- Read the documentation thoroughly
- Check existing issues and discussions
- Ask questions in issue comments
- Be specific about your problem
- Provide relevant context and configuration

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

## Recognition

Contributors will be recognized in:
- Pull request acknowledgments
- Release notes
- Project documentation (for significant contributions)

## Questions?

If you have questions about contributing:
- Open an issue with the "question" label
- Review existing documentation
- Look at previous pull requests for examples

Thank you for contributing to make this module better!
