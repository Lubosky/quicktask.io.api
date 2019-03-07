Connections::RatesConnection = Types::RateType.define_connection do
  name 'RateConnection'

  field :totalCount do
    type types.Int

    resolve ->(obj, _args, _ctx) {
      obj.nodes.count
    }
  end
end
