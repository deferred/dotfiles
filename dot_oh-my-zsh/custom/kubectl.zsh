alias fkdp="kubectl get pods --all-namespaces --no-headers -o wide | fzf | awk '{print \$2, \$1}' | xargs -n 2 sh -c 'kubectl describe pod \$0 -n \$1'"
alias fkdelp="kubectl get pods --all-namespaces --no-headers -o wide | fzf | awk '{print \$2, \$1}' | xargs -n 2 sh -c 'kubectl delete pod \$0 -n \$1'"
