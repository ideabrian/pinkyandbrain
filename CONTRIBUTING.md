# Contributing to Pinky & Brain Cluster

Thank you for contributing to the autonomous development cluster!

## Development Workflow

### The Three Roles

1. **brain (Planner)**
   - Receives feature requests
   - Creates technical specifications
   - Sends specs to pinky for implementation

2. **pinky (Executor)**
   - Receives specifications from brain
   - Implements code exactly as specified
   - Sends completion notices to max

3. **max (Reviewer)**
   - Reviews pinky's implementations
   - Tests functionality
   - Merges to main or requests changes

### Workflow Steps

1. **Planning Phase** (brain)
   - Analyze feature request
   - Design architecture
   - Create specification JSON
   - Send to pinky

2. **Implementation Phase** (pinky)
   - Parse specification
   - Create all required files
   - Write production-ready code
   - Self-test (compile, lint)
   - Save to `workflow-output/[FEATURE]/`
   - Notify max

3. **Review Phase** (max)
   - Review code quality
   - Run tests
   - Check integration
   - Merge or request changes

## Messaging Protocol

### Sending Messages

```bash
curl -X POST http://RECIPIENT.local:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "your-machine",
    "to": "recipient-machine",
    "subject": "Subject line",
    "body": "Message content"
  }'
```

### Quick Message Utility

```bash
./gm.sh recipient "Your message here"
```

## Code Standards

### Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Add error handling: `set -euo pipefail`
- Include description comments
- Use meaningful variable names
- Quote variables: `"$variable"`

Example:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Description: This script does X
# Usage: ./script.sh <arg>

RECIPIENT="${1:-brain}"
MESSAGE="${2:-Hello}"

curl -X POST "http://${RECIPIENT}.local:3100/send" \
  -H "Content-Type: application/json" \
  -d "{\"from\":\"$(hostname)\",\"to\":\"$RECIPIENT\",\"body\":\"$MESSAGE\"}"
```

### JavaScript/Node.js

- Use ES6+ syntax
- Async/await for promises
- Proper error handling
- Clear function names

Example:
```javascript
async function sendMessage(to, body) {
  try {
    const response = await fetch(`http://${to}.local:3100/send`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ from: 'sender', to, body })
    });
    return await response.json();
  } catch (error) {
    console.error('Failed to send message:', error);
    throw error;
  }
}
```

### TypeScript/React

- Use functional components
- Type all props and state
- Use hooks appropriately
- Keep components focused

Example:
```typescript
import React, { useState } from 'react';

interface CounterProps {
  initialValue?: number;
}

export const Counter: React.FC<CounterProps> = ({ initialValue = 0 }) => {
  const [count, setCount] = useState(initialValue);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
};
```

## Git Workflow

### Branching

For new features:
```bash
git checkout -b feature/feature-name
```

For bug fixes:
```bash
git checkout -b fix/bug-description
```

### Commits

Use descriptive commit messages:
```
feat: Add autonomous message polling
fix: Resolve PATH issue in cloud-poller
docs: Update setup guide with SSH instructions
refactor: Simplify message routing logic
```

### Before Committing

1. Test your changes
2. Run linters if available
3. Update documentation if needed
4. Ensure no secrets are included

### Commit Message Format

```
<type>: <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

## Testing

### Manual Testing

1. Test on local machine first
2. Verify message sending/receiving
3. Check error handling
4. Test edge cases

### Integration Testing

1. Test across all three machines
2. Verify workflow completion
3. Check cloud deployments
4. Validate knowledge base updates

## Security Guidelines

### Never Commit

- `.env` files
- API keys or tokens
- SSH private keys
- `CONTEXT.json` (contains runtime data)
- Session state files
- Credentials or secrets

### Use .gitignore

Ensure sensitive files are in `.gitignore`:
```
.env
.env.local
*.key
*.pem
**/credentials.json
CONTEXT.json
session-state.json
```

### API Key Management

- Store keys in `.env` files
- Use `.env.example` for templates
- Rotate keys regularly
- Never log keys

## Voting on Changes

For major architectural changes:

1. Create a vote:
```bash
./vote-simple.sh "Should we implement feature X?" "yes,no,later"
```

2. All machines vote:
```bash
# Vote yes
echo "yes" > votes/vote-1-pinky.txt

# Vote no
echo "no" > votes/vote-1-brain.txt
```

3. Check results:
```bash
ls -la votes/
cat votes/vote-1-*.txt
```

## Documentation

### Required Documentation

For new features:
- Update README.md if user-facing
- Add to docs/ if complex
- Include usage examples
- Document configuration

### Documentation Style

- Use clear, concise language
- Include code examples
- Add troubleshooting tips
- Keep it up-to-date

## Cloudflare Deployment

### Workers

```bash
cd cloudflare/workers/your-worker
wrangler deploy
```

### Pages

```bash
cd cloudflare/pages/your-page
wrangler pages deploy dist
```

### Testing Deployments

1. Test locally first: `wrangler dev`
2. Deploy to staging (if available)
3. Verify in production
4. Monitor for errors

## Troubleshooting Contributions

### Message Not Received

1. Check message bus: `curl http://localhost:3100/inbox`
2. Verify hostname: `ping recipient.local`
3. Check port 3100 is open
4. Review logs: `tail -f messenger.log`

### Code Not Compiling

1. Check dependencies: `npm install`
2. Verify TypeScript config
3. Run linter: `npm run lint`
4. Check for type errors

### SSH Issues

1. Test connection: `ssh machine.local "echo test"`
2. Check keys: `ls -la ~/.ssh/`
3. Verify authorized_keys
4. Re-run setup: `./setup-brain-ssh.sh`

## Getting Help

- Check documentation in `docs/`
- Review existing scripts for examples
- Send message to brain for architectural questions
- Send message to max for integration questions

## Pull Request Process

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Commit with clear messages
5. Push to GitHub
6. Create pull request
7. Wait for review from max
8. Address feedback
9. Merge when approved

## Code of Conduct

- Respect the role of each machine
- Follow the established workflow
- Test before committing
- Document significant changes
- Keep secrets secure
- Communicate clearly via messages

## Questions?

Send a message to the cluster:
```bash
./gm.sh brain "Question about feature X"
```

Thank you for contributing to the autonomous future of software development!
