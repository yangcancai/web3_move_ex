defmodule Web3MoveEx.SuiTest do
  @moduledoc false
  alias Web3MoveEx.Sui.RPC
  alias Web3MoveEx.Sui
  use ExUnit.Case, async: true
  require Logger

  setup_all do
    {:ok, rpc} = RPC.connect("http://127.0.0.1:9000")
    {:ok, %Web3MoveEx.Sui.Account{sui_address_hex: sui_address}} = Sui.generate_priv()
    %{rpc: rpc, address: sui_address}
  end

  test "get_balance", %{rpc: rpc, address: account} do
    res = Sui.get_balance(rpc, account)

    assert {:ok,
            %{
              coinType: "0x2::sui::SUI",
              coinObjectCount: 0,
              totalBalance: 0,
              lockedBalance: {}
            }} == res
  end

  test "test unsafe_moveCall", %{rpc: client} do
    %Web3MoveEx.Sui.Account{sui_address_hex: sui_address_hex} =
    account = Web3MoveEx.Sui.Account.from("AMSs6F3/uRvzqCXXinpSQLpn+d5wH8lWlN2w1a2T7XCW")
    package_object_id = "0x2"
    module = "sui"
    function = "transfer"
    type_arguments = []
    # gas= "0xf4a182bb3a944efb225fd35222e7aa8f18648ea21eb1de9c693541fd1921804f"
    gas_budget = 10000
    arguments = ["0x8fb7a1429d2f57303d742f41fcf7fad701576512d7ecce60713ea1043128842f", "0x7c70bccddbc9f441739613be2320a634d907a6c7e696930fd7f396a9e4c41f93"]
    # {:ok, %{txBytes: tx_bytes}} =
    #   res =
    Web3MoveEx.Sui.move_call(
      client,
      account,
      package_object_id,
      module,
      function,
      type_arguments,
      arguments,
      gas_budget
    )
  end

  test "transfer", %{rpc: client} do
    %Web3MoveEx.Sui.Account{sui_address_hex: sui_address_hex} =
      account = Web3MoveEx.Sui.Account.from("AKpjfApmHx8FbjrRRSrUlF6ITigjP8NMS1ip4JdqPp5g")

    object_id = "0x8fb7a1429d2f57303d742f41fcf7fad701576512d7ecce60713ea1043128842f"
    recipient = "0x313c133acaf25103aae40544003195e1a3bb7d5b2b11fd4c6ec61af16bcdb968"
    gas_old = "0x790a453dac39d5d0c308b01ad26ccec3ba856cedca7e97d0c51e40addbff9a50"

    {:ok, %{effects: %{status: %{status: status}}}} =
      res = client |> Web3MoveEx.Sui.transfer(account, object_id, gas_old, 10, recipient)

    Logger.debug("#{inspect(res)}")
    assert status == "success"
  end

  test "test gen tx_bytes", %{rpc: client} do
    %Web3MoveEx.Sui.Account{sui_address_hex: sui_address_hex} =
      account = Web3MoveEx.Sui.Account.from("AKpjfApmHx8FbjrRRSrUlF6ITigjP8NMS1ip4JdqPp5g")

    object_id = "0x3a5f70f0bedb661f1e8bc596e308317edb0bdccc5bc86207b45f01db1aad5ddf"
    gas_old = "0xf4a182bb3a944efb225fd35222e7aa8f18648ea21eb1de9c693541fd1921804f"

    gas =
      client
      |> Web3MoveEx.Sui.select_gas(
        account,
        "0xf4a182bb3a944efb225fd35222e7aa8f18648ea21eb1de9c693541fd1921804f"
      )

    recipient = "0x313c133acaf25103aae40544003195e1a3bb7d5b2b11fd4c6ec61af16bcdb968"
    gas_price = client |> RPC.suix_getReferenceGasPrice()
    gas_budget = 1000
    object_ref = Web3MoveEx.Sui.object_ref(client, object_id)
    kind = Web3MoveEx.Sui.Bcs.TransactionKind.transfer_object(recipient, object_ref)

    transaction_data =
      Web3MoveEx.Sui.Bcs.TransactionData.new(kind, sui_address_hex, gas, gas_budget, gas_price)

    {:ok, %{txBytes: tx_bytes}} =
      client
      |> RPC.unsafe_transferObject(sui_address_hex, object_id, gas_old, gas_budget, recipient)

    a = Bcs.encode({:v1, transaction_data}, Web3MoveEx.Sui.Bcs.TransactionData)
    b = :base64.decode(tx_bytes)
    assert a == b
  end
end
