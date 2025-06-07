# patched/orchestration.py
# replaces /app/core/base/orchestration.py
from abc import abstractmethod
from enum import Enum
from typing import Any

from .base import Provider, ProviderConfig


class Workflow(Enum):
    INGESTION = "ingestion"
    GRAPH = "graph"


class OrchestrationConfig(ProviderConfig):
    provider: str
    max_runs: int = 2048
    graph_search_results_creation_concurrency_limit: int = 32
    ingestion_concurrency_limit: int = 16
    graph_search_results_concurrency_limit: int = 8

    # ✅ Patched fields to support Hatchet client config
    grpc_host: str = "hatchet-engine"
    grpc_port: int = 7077
    use_tls: bool = False


class OrchestrationProvider(Provider):
    def __init__(self, config: OrchestrationConfig):
        super().__init__(config)
        self.config = config
        self.worker = None

    @abstractmethod
    async def start_worker(self):
        pass

    @abstractmethod
    def get_worker(self, name: str, max_runs: int) -> Any:
        pass

    @abstractmethod
    def step(self, *args, **kwargs) -> Any:
        pass

    @abstractmethod
    def workflow(self, *args, **kwargs) -> Any:
        pass

    @abstractmethod
    def failure(self, *args, **kwargs) -> Any:
        pass

    @abstractmethod
    def register_workflows(
        self, workflow: Workflow, service: Any, messages: dict
    ) -> None:
        pass

    @abstractmethod
    async def run_workflow(
        self,
        workflow_name: str,
        parameters: dict,
        options: dict,
        *args,
        **kwargs,
    ) -> dict[str, str]:
        pass
        
print("✅ Patched OrchestrationConfig loaded.")    