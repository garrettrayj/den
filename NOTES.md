# Development Notes

## Feed Issues

- https://chicago.suntimes.com/rss/news/index.xml broken images
- https://lithub.com/feed/ unable to parse

## Testing Background Tasks

https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development

e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"net.devsci.den.refresh"]
