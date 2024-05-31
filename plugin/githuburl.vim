function! s:FindRoot()
    let l:root = finddir('.git/..', expand('%:p:h') . ';')
    if l:root == ''
        return ''
    endif
    return fnamemodify(l:root, ':p')
endfunction

function s:GetRelativePath(base, target)
    " ansure that target is a subpath of base
    if stridx(a:target, a:base) != 0
        throw "Target is not a subpath of base"
    endif
    return strpart(a:target, len(a:base))
endfunction

function! s:GithubInfo(path)
    let l:git_root = s:FindRoot()
    if l:git_root == ''
        return "Not a git repository"
    endif
    let l:repo_command = printf('cd %s && git config --get remote.origin.url', l:git_root)
    let l:github_url = trim(system(repo_command))
    let l:branch_command = printf('cd %s && git rev-parse --abbrev-ref HEAD', l:git_root)
    let l:current_branch = trim(system('git rev-parse --abbrev-ref HEAD'))
    let l:url_parts = split(l:github_url, '/')
    let l:user = l:url_parts[-2]
    let l:repo = l:url_parts[-1]
    let l:repo = substitute(l:repo, '\.git$', '', '')
    let l:path = s:GetRelativePath(l:git_root, a:path)

    return { 'git_root': l:git_root, 'branch': l:current_branch, 'user': l:user, 'repo': l:repo, 'path': l:path}

endfunction

function! s:PrintGitHubURLs()
    let l:git_info_dict = s:GithubInfo(expand("%:p"))
    echo l:git_info_dict
    let l:user = l:git_info_dict['user']
    let l:repo = l:git_info_dict['repo']
    let l:branch = l:git_info_dict['branch']
    let l:path = l:git_info_dict['path']
    let l:raw_url = printf('https://raw.githubusercontent.com/%s/%s/%s/%s', l:user, l:repo, l:branch, l:path)
    let l:url = printf('https://github.com/%s/%s/blob/%s/%s', l:user, l:repo, l:branch, l:path)
    echo "URL: " . l:url
    echo "URL (raw): " l:raw_url
endfunction

command! PrintGitHubURLs call s:PrintGitHubURLs()
